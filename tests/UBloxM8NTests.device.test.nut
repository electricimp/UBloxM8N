// MIT License
//
// Copyright 2019 Electric Imp
//
// SPDX-License-Identifier: MIT
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO
// EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
// OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
// ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.

@include __PATH__+"/../Driver/UbloxM8N.device.lib.nut"

class StubbedUart {

    _cb = null;
    _br = null;
    rPtr = 0;
    _rBuff = null;
    _wBuff = "";

    // API methods
    // -------------------------------------------------

    function configure(baudRate, wordSize, parity, stopBits, ctsRts, callback) {
        _cb = callback;
        _br = baudRate;
        // NOTE: Do not reset write buffer when configuring - only reset on clearWriteBuffer
        // This allows us to test commands in the UBX Driver configure method.
    }

    function flush() {
        // Not needed since we are not actually sending anything down the wire
    }

    function write(data) {
        // Stores all incoming data as a string
        // server.log(data);
        _wBuff += data.tostring();
    }

    function read() {
        if (_rBuff == null || _rBuff.len() == 0 || rPtr >= _rBuff.len()) {
            _rBuff = null;
            rPtr = 0;
            return -1;
        }

        return _rBuff[rPtr++];
    }

    // Custom test helpers
    // -------------------------------------------------

    // Writes data to read buffer and triggers callback
    function setReadBuffer(data) {
        switch(typeof data) {
            case "string":
                _rBuff = blob(data.len());
                _rBuff.writestring();
                if (_cb) _cb();
                break;
            case "blob":
                _rBuff = data;
                if (_cb) _cb();
                break;
        }
    }

    // Returns write buffer
    function getWriteBuffer() {
        return _wBuff;
    }

    function clearWriteBuffer() {
        _wBuff = "";
    }
}

class UbxM8NTests extends ImpTestCase {

    _testUart = null;
    _ubx = null;

    function setUp() {
        _testUart = StubbedUart();
        _ubx = UBloxM8N(_testUart);
        return "SetUp complete";
    }

    function testBootTimeout() {
        // NOTE: configure also has a boot delay, this is not included in this test.
        local delay = 5;
        local delayUart = StubbedUart();
        local bootUbx = UBloxM8N(delayUart, delay);

        // writeUBX - Expected length 18
        bootUbx.writeUBX(0x0000, "delay test");
        // writeNMEA - Expected length 43
        bootUbx.writeNMEA("$GPVTG,054.7,T,034.4,M,005.5,N,010.2,K*48\n\r");
        // writeMessage - Expected length 10
        bootUbx.writeMessage("delay test");

        // 71 = 18 + 43 + 10
        local expectedBuffer = blob(71);
        expectedBuffer.writestring("\xb5\x62\x00\x00\x0a\x00\x64\x65\x6c\x61\x79\x20\x74\x65\x73\x74\xf9\xc3");
        expectedBuffer.writestring("$GPVTG,054.7,T,034.4,M,005.5,N,010.2,K*48\n\r");
        expectedBuffer.writestring("delay test");

        // Make sure buffer is empty after write(s), but before delay completed
        imp.wakeup(0, function() {
            local buff = delayUart.getWriteBuffer();
            assertTrue(buff.len() == 0, "Write buffer was not empty, boot delay not not complete.");
        }.bindenv(this))

        return Promise(function(resolve, reject) {
            imp.wakeup((delay + 1), function() {
                local buff = delayUart.getWriteBuffer();
                delayUart.clearWriteBuffer();
                assertTrue(buff.len() > 0, "Write buffer was still empty 1s after boot delay complete.");
                assertTrue(crypto.equals(expectedBuffer, buff));
                return resolve("Write commands delayed until after boot timeout completed.");
            }.bindenv(this))
        }.bindenv(this));
    }

    function testRegisterOnMessageCallback() {
        // Make sure we are starting with no message handlers.
        if (_ubx._msgHandlers.len() != 0) _ubx._msgHandlers = {};

        // Register a callback
        _ubx.registerOnMessageCallback(UBLOX_M8N_CONST.DEFAULT_ON_MSG, function(msg, id = null) {}.bindenv(this));
        assertTrue(_ubx._msgHandlers.len() == 1);
        assertTrue(UBLOX_M8N_CONST.DEFAULT_ON_MSG in _ubx._msgHandlers);
        _ubx.registerOnMessageCallback(UBLOX_M8N_CONST.DEFAULT_ON_MSG, null);
        assertTrue(_ubx._msgHandlers.len() == 0);
        assertTrue(!(UBLOX_M8N_CONST.DEFAULT_ON_MSG in _ubx._msgHandlers));

        return "Registering and unregistering message callback test passing.";
    }

    function testWriteUBX() {
        // Check write buffer for expected UBX packet
        local classId = 0x0623;
        local payload = "\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00";
        local expected = "\xb5\x62\x06\x23\x28\x00\x00\x00\x00\x04\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x56\x24";

        // Clear the write buffer
        _testUart.clearWriteBuffer();

        // Write UBX
        _ubx.writeUBX(classId, payload);

        // Check write buffer for expected packet
        local buff = _testUart.getWriteBuffer();
        assertTrue(crypto.equals(expected, buff), "Write UBX method did not format expected UBX message");

        // Clean up write buffer
        _testUart.clearWriteBuffer();
        return "UBX packet correctly formatted.";
    }

    function testWriteNMEA() {
        // Check write buffer for expected sentences
        // Test sentences with and w/o checksum, start char, and ending chars
        local expected = "$GPGLL,4916.45,N,12311.12,W,225444,A,*1d\n\r";
        local noEnding = "$GPGLL,4916.45,N,12311.12,W,225444,A,*1d";
        local noStarting = "GPGLL,4916.45,N,12311.12,W,225444,A,*1d\n\r";
        local noCheckSum = "GPGLL,4916.45,N,12311.12,W,225444,A,";
        local astButNoCheckSum = "$GPGLL,4916.45,N,12311.12,W,225444,A,*";

        // Clear the write buffer
        _testUart.clearWriteBuffer();
        // Write full sentence
        _ubx.writeNMEA(expected);
        local buff = _testUart.getWriteBuffer();
        assertEqual(expected, buff, "NMEA full sentence write error");

        // Clear the write buffer
        _testUart.clearWriteBuffer();
        // Write full sentence
        _ubx.writeNMEA(noEnding);
        local buff = _testUart.getWriteBuffer();
        assertDeepEqual(expected, buff, "NMEA no ending chars sentence write error");

        // Clear the write buffer
        _testUart.clearWriteBuffer();
        // Write full sentence
        _ubx.writeNMEA(noStarting);
        local buff = _testUart.getWriteBuffer();
        assertEqual(expected, buff, "NMEA no start char sentence write error");

        // Clear the write buffer
        _testUart.clearWriteBuffer();
        // Write full sentence
        _ubx.writeNMEA(noCheckSum);
        local buff = _testUart.getWriteBuffer();
        assertEqual(expected, buff, "NMEA no check sum sentence write error");

        // Clear the write buffer
        _testUart.clearWriteBuffer();
        // Write full sentence
        _ubx.writeNMEA(astButNoCheckSum);
        local buff = _testUart.getWriteBuffer();
        assertEqual(expected, buff, "NMEA * but no check sum sentence write error");

        // Clear the write buffer
        _testUart.clearWriteBuffer();
        return "NMEA sentence correctly formatted.";
    }

    function testWriteMessage() {
        // Check write buffer for expected packet
        local assistPacket = "\xb5\x62\x13\x40\x18\x00\x10\x00\x00\x12\xe3\x07\x01\x19\x16\x3a\x24\x00\x80\xab\xd7\x29\x0a\x00\x00\x00\x00\x00\x00\x00\x3a\x78";

        // Clear the write buffer
        _testUart.clearWriteBuffer();

        // Write message
        _ubx.writeMessage(assistPacket);

        // Check write buffer for expected packet
        local buff = _testUart.getWriteBuffer();
        assertTrue(crypto.equals(assistPacket, buff), "Write message method did not write message as expected.");

        // Clean up write buffer
        _testUart.clearWriteBuffer();
        return "Packet written to uart as expected.";
    }

    function testCalcUbxChecksum() {
        // Test that expected check sum is returned

        local packet = "\x13\x40\x18\x00\x10\x00\x00\x12\xe3\x07\x01\x19\x16\x3a\x24\x00\x80\xab\xd7\x29\x0a\x00\x00\x00\x00\x00\x00\x00";
        local expectedCS = "\x3a\x78";

        local actualCS = _ubx.calcUbxChecksum(packet);
        assertTrue(crypto.equals(expectedCS, actualCS), "UBX check sum calculation error");

        return "Expected UBX check sum returned.";
    }

    function testCalcNMEAChecksum() {
        // Test that expected check sum is returned

        local withAst = "$GPVTG,054.7,T,034.4,M,005.5,N,010.2,K*";
        local withOutAst = "$GPVTG,054.7,T,034.4,M,005.5,N,010.2,K";
        local expectedCS = "48";

        local actualWith = _ubx.calcNMEACheckSum(withAst);
        assertTrue(crypto.equals(expectedCS, format("%02x" actualWith)), "NMEA check sum from sentence with * calculation error");

        local actualWithout = _ubx.calcNMEACheckSum(withOutAst);
        assertTrue(crypto.equals(expectedCS, format("%02x" actualWithout)), "NMEA check sum from sentence without * calculation error");

        return "Expected NMEA check sum returned.";
    }

    function testConfigure() {
        // configure - handlers set, configure commands change modes (manual test), baud rate
        if (_ubx._booting) {
            // Driver is still booting, run tests async
            return Promise(function (resolve, reject) {
                imp.wakeup(_ubx._bootTimeout, function() {
                    _runConfigureTest();
                    resolve("Configure method working as expected.");
                }.bindenv(this))
            }.bindenv(this))
        } else {
            _runConfigureTest();
            return "Configure method working as expected.";
        }
    }

    function _runConfigureTest() {
        // Make sure all baud rates are in sync before test and are set to 9600
        local defaultBaudRate = UBLOX_M8N_CONST.DEFUALT_BAUDRATE;
        local newBaudRate = 115200;
        _ubx._currBaudRate = defaultBaudRate;
        _testUart._br = defaultBaudRate;
        // Clear all onMessage handlers
        _ubx._msgHandlers = {};
        // Make sure we run both NMEA and UBX commands
        _ubx._inputMode = null;

        // Expected write buffer
            // NMEA command that sets input and output mode
            // UBX command that sets input and output mode
            // UBX command that updates uart baud rate
        local expected = "$PUBX,41,1,0003,0001,9600,0*16\n\r\xb5\x62\x06\x00\x14\x00\x01\x00\x00\x00\xc0\x08\x00\x00\x80\x25\x00\x00\x03\x00\x01\x00\x00\x00\x00\x00\x8c\x89\xb5\x62\x06\x00\x14\x00\x01\x00\x00\x00\xc0\x08\x00\x00\x00\xc2\x01\x00\x03\x00\x01\x00\x00\x00\x00\x00\xaa\x52";

        // Use options to change baudrate, and set input and output modes
        local opts = {
            "baudRate" : newBaudRate,
            "outputMode" : UBLOX_M8N_MSG_MODE.UBX_ONLY,
            "inputMode" : UBLOX_M8N_MSG_MODE.BOTH
        }
        _ubx.configure(opts);

        // No handlers were set
        assertTrue(_ubx._msgHandlers.len() == 0, "Configure without onMessage callback unexpectedly set onMessage callbacks.");
        // Write buffer matches expected
        assertTrue(crypto.equals(expected, _testUart.getWriteBuffer()), "Expected configure write commands did not equal actual write buffer.");
        // Baud rate updated
        assertTrue(_ubx._currBaudRate == opts.baudRate && _testUart._br == _ubx._currBaudRate, "Baud rate did not update");
        // Clear the write buffer
        _testUart.clearWriteBuffer();

        // Update handlers & check that default options are set correctly
            // No NMEA command
            // One UBX command that sets input and output modes to both and keeps baudrate at 115200
            // NOTE : update checksum
        expected = "\xb5\x62\x06\x00\x14\x00\x01\x00\x00\x00\xc0\x08\x00\x00\x00\xc2\x01\x00\x03\x00\x03\x00\x00\x00\x00\x00\xac\x5e";
        local d = "default";
        local n = "NMEA";
        local u = "UBX";

        // Check onMessage callbacks are set as expected
        opts = {
            "defaultOnMsg" : function(msg, id = null) {return d;},
            "onNmeaMsg" : function(sentence) {return n;},
            "onUbxMsg" : function(payload, id) {return u;}
        }
        _ubx.configure(opts);

        // Write buffer matches expected
        assertTrue(crypto.equals(expected, _testUart.getWriteBuffer()), "Expected default configure write commands did not equal actual write buffer.");
        // Baud rate updated
        assertTrue(_ubx._currBaudRate == newBaudRate && _testUart._br == _ubx._currBaudRate, "Baud rate changed when it shouldn't have.");
        // Clear the write buffer
        _testUart.clearWriteBuffer();
        // Test andlers were set
        assertTrue(_ubx._msgHandlers.len() == 3, "Configure with onMessage callback did not set any onMessage callbacks.");
        assertTrue(_ubx._msgHandlers[UBLOX_M8N_CONST.DEFAULT_ON_MSG](null) == d, "Default onMessage not set to expected callback.");
        assertTrue(_ubx._msgHandlers[UBLOX_M8N_CONST.ON_NMEA_MSG](null) == n, "NMEA onMessage not set to expected callback.");
        assertTrue(_ubx._msgHandlers[UBLOX_M8N_CONST.ON_UBX_MSG](null, null) == u, "UBX onMessage not set to expected callback.");

        // Clear all onMessage handlers
        _ubx._msgHandlers = {};
    }

    // function testEnableUbxMsg() {
    //     // enableUbxMsg - check hander set removed as expected, command correctly formatted
    //     return "Enable UBX Msg method working as expected.";
    // }

    // function testReceiveBoth() {
    //     // Test general message receives both NMEA and UBX messages
    //     return "General onMessage callback working as expected.";
    // }

    // function testReceiveUBX() {
    //     // Test UBX handler, general handler not triggered
    //     return "UBX onMessage callback working as expected.";
    // }

    // function testReceiveUBXMessageSpecific() {
    //     // Test UBX message specific, UBX handler and general handler not triggered
    //     return "UBX message specific onMessage callback working as expected.";
    // }

    // function testReceiveNMEA() {
    //     // Test UBX handler, general handler not triggered
    //     return "NMEA onMessage callback working as expected.";
    // }

    function tearDown() {
        _testUart = null;
        _ubx = null;
        return "Test finished";
    }
}
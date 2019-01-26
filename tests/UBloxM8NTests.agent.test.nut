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
    _wBuff = null;

    // API methods
    // -------------------------------------------------

    function configure(baudRate, wordSize, parity, stopBits, ctsRts, callback) {
        _cb = callback;
        _br = baudRate;
    }

    function flush() {
        _rBuff = null;
        rPtr = 0;
    }

    function write(data) {
        _wBuff = data;
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
    function setReadBuffer(data) {
        return _wBuff;
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
        local bootTime = hardware.millis();
        // initialize, set _msgHandlers[UBLOX_M8N_CONST.DEFAULT_ON_MSG]
        // writeMessage
        // writeNMEA
        // writeUBX
        // configure (don't test??)
    }

    function tearDown() {
        return "Test finished";
    }

    // boot timeout works
    // configure - handlers set, configure commands change modes (manual test), baud rate
    // registerOnMessageCallback - hander added and removed as expected
    // enableUbxMsg - check hander set removed as expected, command correctly formatted
    // writeUBX - packet is formed correctly??
    // writeNMEA - sentence is formed correctly (test all different types of sentences)
    // writeMessage - entry is written
    // calcUbxChecksum - check for expected value
    // calcNMEACheckSum - check for expected expected

    // messages bubble up to correct handlers (general, ubx, nmea, message specific)
}
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


enum UBLOX_M8N_CONST {
    UBX_SYNC_CHAR_1          = 0xB5,
    UBX_SYNC_CHAR_2          = 0x62,
    UBX_CFG_PRT_CLASS_MSG_ID = 0x0600,      // Used in driver class configure
    UBX_CFG_MSG_CLASS_MSG_ID = 0x0601,      // Used in driver class enableUBXMsg
    UBX_MGA_ACK_CLASS_ID     = 0x1360,
    UBX_MON_VER_CLASS_ID     = 0x0a04,

    NMEA_CONFIG_MSG_HEADER   = "PUBX,41",
    NMEA_LINE_MAX            = 150,
    NMEA_START_CHAR          = '$',         // 0x24
    NMEA_END_CHAR_1          = '\n',        // CARRIAGE_RETURN, 2nd to last end char
    NMEA_END_CHAR_2          = '\r',        // LINE_FEED, last end char

    DEFUALT_BAUDRATE         = 9600,
    DEFUALT_UBX_BAUDRATE     = 115200,
    DEFAULT_UART_MODE        = 0x000008c0,  // 8 bit word size, parity none, stop bit 1

    DEFAULT_BOOT_TIMEOUT     = 1,
    DEFAULT_CONFIG_WAIT      = 0.1,

    DEFAULT_PORT             = 0x01,

    DEFAULT_ON_MSG           = "default",
    ON_NMEA_MSG              = "nmea",
    ON_UBX_MSG               = "ubx",

    ASSIST_NOW_ERROR         = "Error: Message callback for %i used by Assist Now library. Use Assist Now class methods to get message payload"
}

enum UBLOX_M8N_MSG_MODE {
    // Note: These values are the bitfield masks used in payload of CFG_PRT command
    UBX_ONLY    = 0x0001,
    NMEA_ONLY   = 0x0002,
    BOTH        = 0x0003,
}

/**
 * The device-side library driver for UBLOX M8N GPS modules. This class wraps some of the commands as defined by [Reciever
 * Description Including Protocol Specification document](https://www.u-blox.com/sites/default/files/products/documents/u-blox8-M8_ReceiverDescrProtSpec_%28UBX-13003221%29_Public.pdf)
 *
 * @class
 */
class UBloxM8N {

    static VERSION = "1.0.1";

    _currBaudRate = null;
    _gpsuart      = null;
    _booting      = null;
    _bootTimeout  = null;
    _inputMode    = null;

    _pointer      = null;
    _buffer       = null;
    _collecting   = null;

    _msgHandlers  = null;

    // For AssistNow Compatibility
    blockAssistNowMsgCallbacks = false;

    /**
     * Initializes Ublox M8N driver object. The constructor will initialize the specified hardware.uart object
     * using either the specified baud rate or a default baud rate of 9600 (the default baud rate specified
     * in the Ublox data sheet).
     *
     * @constructor
     * @param {imp::uart} uart - An uninitialized imp API hardware.uart object that is connected to the M8N GPS module.
     * @param {integer} [bootTimeoutSec = UBLOX_M8N_CONST.DEFAULT_BOOT_TIMEOUT] - Time in seconds to wait before sending
     *      commands to GPS after booting.
     * @param {integer}  [baudRateAtBoot = UBLOX_M8N_CONST.DEFUALT_BAUDRATE] - The baud rate the M8N boots at, used to
     *      configure the imp uart.
     */
    constructor(uart, bootTimeoutSec = UBLOX_M8N_CONST.DEFAULT_BOOT_TIMEOUT, baudRateAtBoot = UBLOX_M8N_CONST.DEFUALT_BAUDRATE) {
        local rt = getroottable();
        if ("UBloxAssistNow" in rt) blockAssistNowMsgCallbacks = true;

        _currBaudRate = baudRateAtBoot;
        _gpsuart = uart;
        _gpsuart.configure(_currBaudRate, 8, PARITY_NONE, 1, NO_CTSRTS, _createUartCallback(UBLOX_M8N_MSG_MODE.BOTH));

        _msgHandlers = {};

        _booting = true;
        _bootTimeout = bootTimeoutSec;
        imp.wakeup(_bootTimeout, function() {
            _booting = false;
        }.bindenv(this))
    }

    /**
     * @typedef {table} ConfigOpts
     * @property {integer} [baudRate] - an updated uart baud rate.
     * @property {UBLOX_M8N_MSG_MODE} [outputMode] - enum that specifies the type(s) of messages the M8N
     *      should output.
     * @property {UBLOX_M8N_MSG_MODE} [inputMode] - enum that specifies the type(s) of of input
     *      messages the M8N will accept.
     * @property {onMessageReceivedCallback} [onNmeaMsg] - handler for incoming NMEA messages from
     *      the M8N. All fully formed NMEA sentences from the M8N will be passed to this handler.
     * @property {onMessageReceivedCallback} [onUbxMsg] - handler for incoming UBX messages from the
     *      M8N. All fully formed UBX packets from the M8N will be passed to this handler only if no message
     *      specific handler is defined.
     * @property {onMessageReceivedCallback} [defaultOnMsg] - handler for all incoming messages from
     *      the M8N. This handler is used only if a message has no other handlers defined.
     */
    /**
     * Configures the uart baud rate, defines the message type(s) the M8N will accept, defines the message type(s)
     * the M8N will send, and sets default message handlers for incoming messages from the M8N. This method will
     * re-configure the uart bus.
     *
     * @param {ConfigOpts} opts - configuration options
     */
    /**
     * Callback to be executed when a fully formed NMEA sentence or UBX message is received from the M8N.
     *
     * @callback onMessageReceivedCallback
     * @param {blob/string} payload - NMEA sentence or UBX message payload.
     * @param {integer} [classId] - UBX message class and id. The defaultOnMsg and onUbxMsg will use this parameter.
     *      UBX message specific handlers and NMEA handlers do not pass anything to this parameter.
     */
    function configure(opts) {
        if (_booting) {
            imp.wakeup(_bootTimeout, function() {
                configure(opts);
            }.bindenv(this))
            return;
        }

        local baudrate = ("baudRate" in opts) ? opts.baudRate : _currBaudRate;
        local output   = ("outputMode" in opts) ? opts.outputMode : UBLOX_M8N_MSG_MODE.BOTH;
        local input    = ("inputMode" in opts) ? opts.inputMode : UBLOX_M8N_MSG_MODE.BOTH;
        if ("defaultOnMsg" in opts)  _msgHandlers[UBLOX_M8N_CONST.DEFAULT_ON_MSG] <- opts.defaultOnMsg;
        if ("onNmeaMsg" in opts)  _msgHandlers[UBLOX_M8N_CONST.ON_NMEA_MSG] <- opts.onNmeaMsg;
        if ("onUbxMsg" in opts)  _msgHandlers[UBLOX_M8N_CONST.ON_UBX_MSG] <- opts.onUbxMsg;

        // We do not know input mode for sure
        if (_inputMode == null) {
            // Send first command in both UBX and NMEA format with current UART settings
            local nmeaCmd = format("%s,%i,%04x,%04x,%i,0", UBLOX_M8N_CONST.NMEA_CONFIG_MSG_HEADER, UBLOX_M8N_CONST.DEFAULT_PORT, input, output, _currBaudRate);
            writeNMEA(nmeaCmd);
            _gpsuart.flush();
            imp.sleep(UBLOX_M8N_CONST.DEFAULT_CONFIG_WAIT);

            local ubxPayload = _getUbxCfgPrtPayload(_currBaudRate, input, output);
            writeUBX(UBLOX_M8N_CONST.UBX_CFG_PRT_CLASS_MSG_ID, ubxPayload);
            _gpsuart.flush();
            imp.sleep(UBLOX_M8N_CONST.DEFAULT_CONFIG_WAIT);
        }

        if (_inputMode != null || baudrate != _currBaudRate) {
            // We still need to send a config command, update locally stored settings
            _inputMode = input;
            _currBaudRate = baudrate;

            // Send command
            if (_inputMode == UBLOX_M8N_MSG_MODE.NMEA_ONLY) {
                local nmeaCmd = format("%s,%i,%04x,%04x,%i,0", UBLOX_M8N_CONST.NMEA_CONFIG_MSG_HEADER, UBLOX_M8N_CONST.DEFAULT_PORT, input, output, _currBaudRate);
                writeNMEA(nmeaCmd);
                _gpsuart.flush();
                imp.sleep(UBLOX_M8N_CONST.DEFAULT_CONFIG_WAIT);
            } else {
                local ubxPayload = _getUbxCfgPrtPayload(_currBaudRate, input, output);
                writeUBX(UBLOX_M8N_CONST.UBX_CFG_PRT_CLASS_MSG_ID, ubxPayload);
                _gpsuart.flush();
                imp.sleep(UBLOX_M8N_CONST.DEFAULT_CONFIG_WAIT);
            }
        } else {
            // We have already sent command, update stored setting
            _inputMode = input;
        }

        // Update UART with appropriate RX handler and/or baudrate
        _gpsuart.configure(_currBaudRate, 8, PARITY_NONE, 1, NO_CTSRTS, _createUartCallback(_inputMode));
    }

    /**
     * Registers a message handlers for incoming messages from the M8N.
     *
     * @param {String/Integer} type - Either the UBX the 2 byte message class and ID, or one of the following
     *      handler types: UBLOX_M8N_CONST.DEFAULT_ON_MSG, UBLOX_M8N_CONST.ON_NMEA_MSG,
     *      UBLOX_M8N_CONST.ON_UBX_MSG
     * @param {onMessageReceivedCallback} handler - the function that is triggered when the specified message
     *      is received from the M8N. Passing null to the onMessage will unregister the callback. Note: only
     *      one handler will be triggered for each incoming message. If a message specific handler is
     *      registered that handler will be called. If no message specific handler is registered the UBX or
     *      NMEA message handlers will be used. If no matching handlers are register the general message
     *      handler will be used. If a general message handler is registered it should be able to handle
     *      both NMEA and UBX message formats.
     */
    /**
     * Callback to be executed when a fully formed NMEA sentence or UBX message is received from the M8N.
     *
     * @callback onMessageReceivedCallback
     * @param {blob/string} payload - NMEA sentence or UBX message payload.
     * @param {integer} [classId] - UBX message class and id. All general and UBX handlers must include this
     *      as an optional parameter. NMEA handlers do not need this parameter.
     */
    function registerOnMessageCallback(type, onMessage) {
        if (blockAssistNowMsgCallbacks &&
           (type == UBLOX_M8N_CONST.UBX_MGA_ACK_CLASS_ID || type == UBLOX_M8N_CONST.UBX_MON_VER_CLASS_ID)) {
            throw format(UBLOX_M8N_CONST.ASSIST_NOW_ERROR, type);
        }

        if (onMessage == null) {
            if (type in _msgHandlers) _msgHandlers.rawdelete(type);
        } else {
            _msgHandlers[type] <- onMessage;
        }
    }

    /**
     * Enable UBX messages at the specified rate. When messages are received they will be passed
     * to the onMessage callback. If no onMessage callback is specified messages will be passed to either
     * onUbxMsg or defaultOnMsg callback instead. To disable messages pass a rate of 0 to this method. If messages are disabled the callback will be deleted.
     *
     * @param {integer} classId - the 2 byte message class and Id.
     * @param {integer} rate - how often, in seconds, new messages will be sent.
     * @param {onMessageReceivedCallback} [onMessage] - callback function for incoming messages with this class Id.
     */
    /**
     * Callback to be executed when a fully formed NMEA sentence or UBX message is received from the M8N.
     *
     * @callback onMessageReceivedCallback
     * @param {blob/string} payload - NMEA sentence or UBX message payload.
     */
    function enableUbxMsg(classId, rate, onMessage = null) {
        // Throw error if message used by assist now library
        if (blockAssistNowMsgCallbacks &&
           (classId == UBLOX_M8N_CONST.UBX_MGA_ACK_CLASS_ID || classId == UBLOX_M8N_CONST.UBX_MON_VER_CLASS_ID)) {
            throw format(UBLOX_M8N_CONST.ASSIST_NOW_ERROR, type);
        }

        if (rate == 0 || onMessage == null) {
            // Delete callback
            if (classId in _msgHandlers) _msgHandlers.rawdelete(classId);
        } else if (onMessage != null) {
            // Store callback
            _msgHandlers[classId] <- onMessage;
        }

        // Send command to enable message
        writeUBX(UBLOX_M8N_CONST.UBX_CFG_MSG_CLASS_MSG_ID, format("%c%c%c", classId >> 8, classId, rate));
    }

    /**
     * Writes a UBX protocol packet to the M8N. Note if your command expects a response be sure you have a
     * handler registered.
     *
     * @param {integer} classId - the 2 byte message class and ID.
     * @param {blob/string} payload - the message payload.
     */
    function writeUBX(classId, payload) {
        if (_booting) {
            imp.wakeup(_bootTimeout, function() {
                writeUBX(classId, payload);
            }.bindenv(this))
            return;
        }

        // Form full packet
        local pkt = format("%c%c%c%c", classId >> 8, classId & 0xFF, payload.len() & 0xFF, payload.len() >> 8) + payload;
        local cs = calcUbxChecksum(pkt);

        // Send header, packet, and checksum
        _gpsuart.write(format("%c%c", UBLOX_M8N_CONST.UBX_SYNC_CHAR_1, UBLOX_M8N_CONST.UBX_SYNC_CHAR_2));
        _gpsuart.write(pkt);
        _gpsuart.write(cs);
    }

    /**
     * Writes an NMEA protocol packet to the M8N.
     *
     * @param {string} sentence - an NMEA formatted sentence with comma separated fields. If needed, this method will
     * add the start character, ending characters, and/or check sum to the sentence before writing.
     */
    function writeNMEA(sentence) {
        if (_booting) {
            imp.wakeup(_bootTimeout, function() {
                writeNMEA(sentence);
            }.bindenv(this))
            return;
        }

        // Make sure sentence starts with the correct start character
        if (sentence[0] != UBLOX_M8N_CONST.NMEA_START_CHAR) {
            sentence = format("%c%s", UBLOX_M8N_CONST.NMEA_START_CHAR, sentence);
            // sentence = UBLOX_M8N_CONST.NMEA_START_CHAR + sentence;
        }

        // Add check sum and/or ending characters if needed
        local astIdx = sentence.find("*");

        if (astIdx == null) /*No check sum in sentece, add one*/ {
            // Delete ending characters if there were any
            sentence = strip(sentence);
            // Add check sum and ending characters
            sentence = format("%s*%02x%c%c", sentence, calcNmeaChecksum(sentence), UBLOX_M8N_CONST.NMEA_END_CHAR_1, UBLOX_M8N_CONST.NMEA_END_CHAR_2);
        } else if (astIdx == sentence.len() - 1) /*Last char was *, need to add check sum*/ {
            // Add check sum and ending characters
            sentence = format("%s%02x%c%c", sentence, calcNmeaChecksum(sentence), UBLOX_M8N_CONST.NMEA_END_CHAR_1, UBLOX_M8N_CONST.NMEA_END_CHAR_2);
        } else if (sentence.find(UBLOX_M8N_CONST.NMEA_END_CHAR_1.tochar()) == null || sentence.find(UBLOX_M8N_CONST.NMEA_END_CHAR_2.tochar()) == null) /*Sentence has check sum but is missing termination characters, add them*/ {
            // Delete ending characters if there were any
            sentence = strip(sentence);
            // Add correct ending characters
            sentence = format("%s%c%c", sentence, UBLOX_M8N_CONST.NMEA_END_CHAR_1, UBLOX_M8N_CONST.NMEA_END_CHAR_2);
        }

        // Send sentence
        _gpsuart.write(sentence);
    }

    /**
     * Writes an assist entry.
     *
     * @param {string} entry - An assist entry string
     */
    function writeMessage(entry) {
        if (_booting) {
            imp.wakeup(_bootTimeout, function() {
                writeMessage(entry);
            }.bindenv(this))
            return;
        }

        // Send entry
        _gpsuart.write(entry);
    }

    /**
     * Calculates the check sum for a UBX packet.
     *
     * @param {blob} pkt - Packet must consist of only the following: message class(1 byte),
     * message id (1 byte), payload length (2 bytes), and payload.
     *
     * @returns {string} 2 byte check sum
     */
    function calcUbxChecksum(pkt) {
        local cka=0, ckb=0;
        foreach(a in pkt) {
            cka += a;
            ckb += cka;
        }
        cka = cka & 0xFF;
        ckb = ckb & 0xFF;

        return format("%c%c", cka, ckb);
    }

    /**
     * Calculates the check sum for an NMEA sentence. This method will exclude starting and
     * ending characters when calculating the check sum.
     *
     * @param {string} sentence - NMEA sentence
     *
     * @returns {integer} 1 byte check sum
     */
    function calcNmeaChecksum(sentence) {
        local check = 0;
        local index = (sentence[0] == UBLOX_M8N_CONST.NMEA_START_CHAR) ? 1 : 0;
        while(index < sentence.len() && sentence[index] != '*') {
            check = check ^ (sentence[index++]);
        }
        return check;
    }

    // Helper function that creates a UBX CFG_PRT payload
    function _getUbxCfgPrtPayload(baudrate, input, output) {
        local payload = blob(20);
        payload.writen(UBLOX_M8N_CONST.DEFAULT_PORT, 'b');
        payload.seek(4, 'b');
        payload.writen(UBLOX_M8N_CONST.DEFAULT_UART_MODE, 'i');
        payload.writen(baudrate, 'i');
        payload.writen(input, 'w');
        payload.writen(output, 'w');
        return payload;
    }

    // Helper function that creates a UART callback based on the input message mode
    function _createUartCallback(mode) {
        local processByte;
        switch(mode) {
            case UBLOX_M8N_MSG_MODE.NMEA_ONLY :
                processByte = _processNMEA;
                break;
            case UBLOX_M8N_MSG_MODE.UBX_ONLY :
                processByte = _processUBX;
                break;
            case UBLOX_M8N_MSG_MODE.BOTH :
                processByte = _processByte;
                break;
            default:
                processByte = function(b) {};
        }

        // Return UART RX handler
        return function() {
            local b;
            while((b = _gpsuart.read()) >= 0) {
                processByte(b);
            }
        }.bindenv(this);
    }

    // Helper function that determines how incoming uart byte should be processed when
    // both NMEA and UBX messages are enabled.
    function _processByte(b) {
        switch(_collecting) {
            case UBLOX_M8N_MSG_MODE.NMEA_ONLY:
                _processNMEA(b);
                break;
            case UBLOX_M8N_MSG_MODE.UBX_ONLY:
                _processUBX(b);
                break;
            default:
                if (b == UBLOX_M8N_CONST.NMEA_START_CHAR) {
                    _processNMEA(b);
                } else if (b == UBLOX_M8N_CONST.UBX_SYNC_CHAR_1) {
                    _processUBX(b);
                }
                break;
        }
    }

    // Helper that builds NMEA sentences from incoming UART bytes.
    function _processNMEA(b) {
        // Only process byte if we have a handler
        local handler = null;
        if (UBLOX_M8N_CONST.ON_NMEA_MSG in _msgHandlers) {
            handler = _msgHandlers[UBLOX_M8N_CONST.ON_NMEA_MSG];
        } else if (UBLOX_M8N_CONST.DEFAULT_ON_MSG in _msgHandlers) {
            handler = _msgHandlers[UBLOX_M8N_CONST.DEFAULT_ON_MSG];
        }
        if (handler == null) return;

        if (b == UBLOX_M8N_CONST.NMEA_START_CHAR) {
            // Start a new _buffer
            _buffer = "";
            _buffer += b.tochar();

            // Toggle flag to append data to _buffer
            _collecting = UBLOX_M8N_MSG_MODE.NMEA_ONLY;
        } else if (_buffer != null && _buffer.len() > UBLOX_M8N_CONST.NMEA_LINE_MAX) {
            // Sentence is too long, data must be corrupted
            // Reset _buffer and wait for next start char.
            _buffer = null;
            _collecting = null;
        } else if (_collecting) {
            // Append charater to _buffer
            _buffer += b.tochar();

            // If we just appended the last char in GPS sentence
            // process sentence
            if (b == UBLOX_M8N_CONST.NMEA_END_CHAR_2) {
                // Pass GPS sentence to handler
                handler(_buffer);
                // Reset _buffer
                _buffer = null;
                _collecting = null;
            }
        }
    }

    // Helper that builds UBX packets from incoming UART bytes.
    function _processUBX(b) {
        if (b == UBLOX_M8N_CONST.UBX_SYNC_CHAR_1) {
            _buffer = blob(6);
            _buffer.writen(b, 'b');
            _pointer = 1;
            _collecting = UBLOX_M8N_MSG_MODE.UBX_ONLY;
        } else if (_buffer != null && _pointer > _buffer.len()) {
            // Data collected is too long, data must be corrupted
            // Reset _buffer and wait for next start char.
            _buffer = null;
            _pointer = 0;
            _collecting = null;
        } else if (_collecting) {
            // Add byte to buffer and increment pointer
            _buffer[_pointer] = b;
            _pointer++;

            if (_pointer == 2 && b != UBLOX_M8N_CONST.UBX_SYNC_CHAR_2) {
                // We did not get both sync characters, reset
                _collecting = null;
                _pointer = 0;
                _buffer  = null;
            } else if (_pointer == 6) {
                // We now have the payload length
                // Create blob the length of the expected payload and checksum
                local packet = blob(((_buffer[5] << 8) | _buffer[4]) + 2);

                // Increase buffer size to the length of the expected full packet
                _buffer.seek(0, 'e');
                _buffer.writeblob(packet);
            } else if (_pointer == _buffer.len()) {
                // We have a expected packet bytes
                _validatePacket(_buffer);
                // Reset buffer
                _collecting = null;
                _pointer = 0;
                _buffer  = null;
            }
        }
    }

    // Extract and validate packet from buffer using check sum,
    // If packet is good, pass class/id, and payload to handler
    function _validatePacket(buff) {
        local bLen = buff.len();
        buff.seek(2, 'b');

        // Exclude sync chars(2) and check sum(2)
        local packet = buff.readblob(bLen - 4);
        // Get actual CheckSum
        buff.seek(-2, 'e');
        local actualCheckSum = buff.readstring(2);
        // Calculate CheckSum of packet
        local calcCheckSum = calcUbxChecksum(packet);

        if (actualCheckSum == calcCheckSum) {
            // Packet is valid
            local classId = (packet[0] << 8) | packet[1];
            packet.seek(4, 'b');
            local payload = packet.readblob(bLen);
            _processUBXPacket(classId, payload);
        }
    }

    function _processUBXPacket(classId, payload) {
        // Handle packet based on class id
        if (classId in _msgHandlers) {
            _msgHandlers[classId](payload);
        } else if (UBLOX_M8N_CONST.ON_UBX_MSG in _msgHandlers) {
            _msgHandlers[UBLOX_M8N_CONST.ON_UBX_MSG](payload, classId);
        } else if (UBLOX_M8N_CONST.DEFAULT_ON_MSG in _msgHandlers) {
            _msgHandlers[UBLOX_M8N_CONST.DEFAULT_ON_MSG](payload, classId);
        }
    }

}
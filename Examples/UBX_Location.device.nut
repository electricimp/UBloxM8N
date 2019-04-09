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

// INCLUDE LIBRARIES
// ----------------------------------------------------------------------------------------

#require "UBloxM8N.device.lib.nut:1.0.1"
#require "UbxMsgParser.lib.nut:2.0.0"

// HELPER FUNCTIONS
// ----------------------------------------------------------------------------------------

function logBlob(b) {
    if (b.len() > 0) {
        local s = "";
        foreach(num in b) {
            s += format("0x%02X ", num);
        }
        return s;
    }
    return "";
}

function logUBX(parsed) {
    if (parsed.error != null) {
        server.error(parsed.error);
        server.log(parsed.payload);
    } else {
        foreach(key, value in parsed) {
            if (typeof value == "blob") {
                server.log(key + ": " + logBlob(value));
            } else {
                server.log(key + ": " + value);
                if (typeof value == "table" || typeof value == "array") {
                    foreach (k, val in value) {
                        local t = typeof val;
                        if (t == blob) {
                            server.log("\t" + k + ": " + logBlob(val))
                        } else {
                            server.log("\t" + k + ": " + val);
                            if (t == "table") {
                                foreach (slot, v in val) {
                                    server.log("\t\t" + slot + ": " + v);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

function ubxMsgHandler(payload, classId) {
    server.log("In ubx msg handler...");
    server.log("--------------------------------------------");

    // Log message info
    server.log(format("Msg Class ID: 0x%04X", classId));
    server.log("Msg len: " + payload.len());

    // Log UBX message
    if (classId in UbxMsgParser) {
        local parsed = UbxMsgParser[classId](payload);
        logUBX(parsed);
    } else {
        server.log(payload);
    }

    server.log("--------------------------------------------");
}

function navMsgHandler(payload) {
    server.log("--------------------------------------------");
    server.log("In NAV_PVT msg handler...");
    server.log("Msg len: " + payload.len());

    local parsed = UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.NAV_PVT](payload);
    logUBX(parsed);

    if ("lat" in parsed && "lon" in parsed) {
        server.log(format("Lat: %s, Lon: %s",
            UbxMsgParser.toDecimalDegreeString(parsed.lat),
            UbxMsgParser.toDecimalDegreeString(parsed.lon)));
    }
    server.log("--------------------------------------------");
}

function satMsgHandler(payload) {
    server.log("--------------------------------------------");
    server.log("In NAV_SAT msg handler...");
    server.log("Msg len: " + payload.len());

    local parsed = UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.NAV_SAT](payload);
    logUBX(parsed);
    server.log("--------------------------------------------");
}

function ackHandler(payload) {
    server.log("In ACK_ACK msg handler...");
    local parsed = UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.ACK_ACK](payload);
    if (parsed.error != null) {
        server.error(parsed.error);
    } else {
        server.log(format("ACK-ed msgId: 0x%04X", parsed.ackMsgClassId));
    }
}

function nakHandler(payload) {
    server.log("In ACK_NAK msg handler...");
    local parsed = UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.ACK_NAK](payload);
    if (parsed.error != null) {
        server.error(parsed.error);
    } else {
        server.error(format("NAK-ed msgId: 0x%04X", parsed.nakMsgClassId));
    }
}

// RUNTIME
// ----------------------------------------------------------------------------------------

server.log("Device running...");
imp.enableblinkup(true);
server.log("Imp Software Version...");
server.log(imp.getsoftwareversion());

// Configure Hardware - impC001 Breakout Board
powergate <- hardware.pinYG;
powergate.configure(DIGITAL_OUT, 1);
gpsUART <- hardware.uartNU;
ubx <- UBloxM8N(gpsUART);

// Configure u-blox in UBX mode
server.log("Configuring u-blox...");
ubx.configure({ "baudRate"   : 115200,
                "outputMode" : UBLOX_M8N_MSG_MODE.UBX_ONLY,
                "inputMode"  : UBLOX_M8N_MSG_MODE.UBX_ONLY,
                "onUbxMsg"   : ubxMsgHandler });

// Register command ACK and NAK callbacks
ubx.registerOnMessageCallback(UBX_MSG_PARSER_CLASS_MSG_ID.ACK_ACK, ackHandler);
ubx.registerOnMessageCallback(UBX_MSG_PARSER_CLASS_MSG_ID.ACK_NAK, nakHandler);

server.log("Get u-blox Software Version...");
ubx.writeUBX(0x0a04, "");

server.log("Enable navigation messages...");
// Satellite Information
ubx.enableUbxMsg(UBX_MSG_PARSER_CLASS_MSG_ID.NAV_SAT, 5, satMsgHandler);
// Position Velocity Time Solution
ubx.enableUbxMsg(UBX_MSG_PARSER_CLASS_MSG_ID.NAV_PVT, 5, navMsgHandler);

imp.wakeup(35, function() {
    // Turn off Satellite Information messages
    ubx.enableUbxMsg(UBX_MSG_PARSER_CLASS_MSG_ID.NAV_SAT, 0, satMsgHandler);
})

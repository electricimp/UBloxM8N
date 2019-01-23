# Examples #

These examples show how to use the UBloxM8N driver, with both the UbxMsgParser (for parsing UBX messages) and GPSParser (for parsing NMEA sentences). All examples run on the device only.

## UBX Location ##

This example shows how to:

- increase the UART baudrate
- configure the M8N to send and receive only UBX messages
- register both a default callback for UBX messages and a number of message specific callbacks
- enable and disable navigation messaging
- gets the module's software version by sending a raw command
- parse and log messages received by the various callbacks

[Code](./UBX_Location.device.nut)

```
// INCLUDE LIBRARIES
// ----------------------------------------------------------------------------------------

#require "UBloxM8N.device.lib.nut:1.0.0"
#require "UbxMsgParser.lib.nut:1.0.0"

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

// Configure Hardware
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
```

## NMEA Location ##

This example shows how to:

- configure the M8N to send and receive only NMEA messages
- register both a default callback for NMEA messages
- parse and log location data from an NMEA message

[Code](./NMEA_Location.device.nut)

```
// INCLUDE LIBRARIES
// ----------------------------------------------------------------------------------------

#require "UBloxM8N.device.lib.nut:1.0.0"
#require "GPSParser.device.lib.nut:1.0.0"

// HELPER FUNCTIONS
// ----------------------------------------------------------------------------------------

// NOTE: There will be a ton of NMEA messages. Comment out test logs to just receive location
// logging.
function nmeaMsgHandler(sentence) {
    // Test logs
    server.log("In nmea msg handler...");
    server.log("--------------------------------------------");
    // Log NMEA sentence
    server.log(sentence);
    server.log("--------------------------------------------");

    // Location logs
    local gpsData = GPSParser.getGPSDataTable(sentence);
    if (gpsData.sentenceId == "GGA") {
        // Only log if we have a fix
        if ("fixQuality" in gpsData && gpsData.fixQuality != "0") {
            foreach(key, value in gpsData) {
                server.log(key + ": " + value);
            }
        }
    }

}

// RUNTIME
// ----------------------------------------------------------------------------------------

server.log("Device running...");
imp.enableblinkup(true);
server.log("Imp Software Version...");
server.log(imp.getsoftwareversion());

// Configure Hardware
powergate <- hardware.pinYG;
powergate.configure(DIGITAL_OUT, 1);
gpsUART <- hardware.uartNU;
ubx <- UBloxM8N(gpsUART);

// Configure u-blox in MNEA mode
server.log("Configuring u-blox...");
ubx.configure({ "outputMode" : UBLOX_M8N_MSG_MODE.NMEA_ONLY,
                "inputMode"  : UBLOX_M8N_MSG_MODE.NMEA_ONLY,
                "onNmeaMsg"  : nmeaMsgHandler });
```

## UBX and NMEA Location ##

These examples shows how to:

- configure the M8N to send and receive both UBX and NMEA messages
- use a single onMessage callback to process data
- parse and log location data

[Code](./UBX_NMEA_Location.device.nut)

```
// INCLUDE LIBRARIES
// ----------------------------------------------------------------------------------------

#require "UBloxM8N.device.lib.nut:1.0.0"
#require "GPSParser.device.lib.nut:1.0.0"
#require "UbxMsgParser.lib.nut:1.0.0"

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
    // Log message info
    server.log("--------------------------------------------");
    server.log(format("Msg Class ID: 0x%04X", classId));
    server.log("Msg len: " + payload.len());

    // Log message payload
    if (classId in UbxMsgParser) {
        local parsed = UbxMsgParser[classId](payload);
        logUBX(parsed);
    } else {
        server.log(payload);
    }
    server.log("--------------------------------------------");
}

function nmeaMsgHandler(sentence) {
    // Log location once we have a fix
    local gpsData = GPSParser.getGPSDataTable(sentence);
    if (gpsData.sentenceId == "GGA") {
        // Only log if we have a fix
        if ("fixQuality" in gpsData && gpsData.fixQuality != "0") {
            server.log("--------------------------------------------");
            server.log("In NMEA-GGA msg handler...");
            foreach(key, value in gpsData) {
                server.log(key + ": " + value);
            }
            server.log("--------------------------------------------");
        }
    }

}

function onMessage(msg, classId = null) {
    if (classId != null) {
        // Received UBX message
        ubxMsgHandler(msg, classId);
     } else {
         // Received NMEA sentence
         nmeaMsgHandler(msg);
     }
}

function navMsgHandler(payload) {
    server.log("--------------------------------------------");
    server.log("In NAV_PVT msg handler...");
    server.log("Msg len: " + payload.len());

    local parsed = UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.NAV_PVT](payload);
    logUBX(parsed);
    server.log("--------------------------------------------");
}

// RUNTIME
// ----------------------------------------------------------------------------------------

server.log("Device running...");
imp.enableblinkup(true);
server.log("Imp Software Version...");
server.log(imp.getsoftwareversion());

// Configure Hardware
powergate <- hardware.pinYG;
powergate.configure(DIGITAL_OUT, 1);
gpsUART <- hardware.uartNU;
ubx <- UBloxM8N(gpsUART);

// Configure u-blox in MNEA mode
server.log("Configuring u-blox...");
ubx.configure({ "outputMode"   : UBLOX_M8N_MSG_MODE.BOTH,
                "inputMode"    : UBLOX_M8N_MSG_MODE.BOTH,
                "defaultOnMsg" : onMessage });

server.log("Get u-blox Software Version...");
ubx.writeUBX(0x0a04, "");

server.log("Enable navigation message...");
// Position Velocity Time Solution
ubx.enableUbxMsg(UBX_MSG_PARSER_CLASS_MSG_ID.NAV_PVT, 5, navMsgHandler);
```

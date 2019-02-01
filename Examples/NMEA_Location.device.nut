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

// Configure Hardware - impC001 Breakout Board
powergate <- hardware.pinYG;
powergate.configure(DIGITAL_OUT, 1);
gpsUART <- hardware.uartNU;
ubx <- UBloxM8N(gpsUART);

// Configure u-blox in MNEA mode
server.log("Configuring u-blox...");
ubx.configure({ "outputMode" : UBLOX_M8N_MSG_MODE.NMEA_ONLY,
                "inputMode"  : UBLOX_M8N_MSG_MODE.NMEA_ONLY,
                "onNmeaMsg"  : nmeaMsgHandler });

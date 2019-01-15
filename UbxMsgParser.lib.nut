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

// Partial list only includes those currently used in the parsing table
enum UBX_MSG_PARSER_CLASS_MSG_ID {
    NAV_PVT   = 0x0107,
    NAV_SAT   = 0x0135,
    ACK_ACK   = 0x0501,
    ACK_NAK   = 0x0500,
    MON_HW    = 0x0a09,
    MON_VER   = 0x0a04,
    MGA_ACK   = 0x1360
}

/**
 * This table contains functions for parsing UBX messages received by UBLOX M8N
 * GPS module. A small number of messages have been selected as a base. This
 * table should be extened by adding more slots if needed. For information about
 * UBX messages see [Reciever Description Including Protocol Specification document](https://www.u-blox.com/sites/default/files/products/documents/u-blox8-M8_ReceiverDescrProtSpec_%28UBX-13003221%29_Public.pdf)
 * All slots in this table are the UBX the 2 byte message class and ID, and values
 * are a function that takes the UBX message payload and returns either a table of
 * parsed payload values or for ack/nak messages the 2 byte message class-id for the
 * ack/nak-ed message. Note: Squirrel only supports signed 32 bit integers. If the
 * paylaod conatins a 32 bit unsigned integer the parsed table will contain a 4 byte
 * blob with the payload values. These values are in the same order as received
 * by the M8N (little endian).
 *
 * @table
 */
UbxMsgParser <- {}

/**
 * Parses 0x0107 (NAV_PVT) UBX message payload.
 *
 * @param {blob} payload - parses 100 byte NAV_PVT message payload.
 *
 * @return {table}
 *      @tableEntry {blob} iTOW - 4 byte unsigened integer, GPS time of week of the navigation epoch in ms.
 *      @tableEntry {integer} year - Year (UTC)
 *      @tableEntry {integer} month - Month, range 1..12 (UTC)
 *      @tableEntry {integer} day - Day of month, range 1..31 (UTC)
 *      @tableEntry {integer} hour - Hour of day, range 0..23 (UTC)
 *      @tableEntry {integer} min - Minute of hour, range 0..59 (UTC)
 *      @tableEntry {integer} sec - Seconds of minute, range 0..60 (UTC)
 *      @tableEntry {table} valid - Validity flags
 *              @tableEntry {bool} validDate - valid UTC Date
 *              @tableEntry {bool} validTime - valid UTC Time of Day
 *              @tableEntry {bool} fullyResolved - UTC Time of Day has been fully resolved (no seconds uncertainty)
 *              @tableEntry {bool} validMag - valid Magnetic declination
 *      @tableEntry {integer} tAcc - Time accuracy estimate in ns (UTC)
 *      @tableEntry {integer} nano - Fraction of second, range -1e9 .. 1e9 in ns (UTC)
 *      @tableEntry {integer} fixType - GNSSfix Type: 0 = no fix, 1 = dead reckoning only,
 *          2 = 2D-fix, 3 = 3D-fix, 4 = GNSS + dead reckoning combined, 5 = time only fix
 *      @tableEntry {table} fixStatusFlags - Fix status flags
 *              @tableEntry {integer} gnssFixOK - 1 = valid fix (i.e within DOP & accuracy masks)
 *              @tableEntry {integer} diffSoln - 1 = differential corrections were applied
 *              @tableEntry {integer} psmState - Power Save Mode state: 0 = PSM is not active,
 *                  1 = Enabled (an intermediate state before Acquisition state), 2 = Acquisition,
 *                  3 = Tracking, 4 = Power Optimized Tracking, 5 = Inactive
 *              @tableEntry {integer} headVehValid - 1 = heading of vehicle is valid
 *              @tableEntry {integer} carrSoln - Carrier phase range solution status (not supported in
 *                  protocol versions less than 20): 0: no carrier phase range solution, 1 = float
 *                  solution (no fixed integer carrier phase measurements have been used to calculate
 *                  the solution), 2 = fixed solution (one or more fixed integer carrier phase range
 *                  measurements have been used to calculate the solution)
 *              @tableEntry {integer} confirmedAvai - (Not supported in all versions) 1 = information
 *                  about UTC Date and Time of Day validity confirmation is available
 *              @tableEntry {integer} confirmedDate - 1 = UTC Date validity could be confirmed
 *              @tableEntry {integer} confirmedTime - 1 = UTC Time of Day could be confirmed
 *      @tableEntry {integer} numSV - Number of satellites used in Nav Solution
 *      @tableEntry {integer} lon - Longitude in deg
 *      @tableEntry {integer} lat - Latitude in deg
 *      @tableEntry {integer} height - Height above ellipsoid in mm
 *      @tableEntry {integer} hMSL - Height above mean sea level mm
 *      @tableEntry {blob} hAcc - 4 byte unsigened integer, Horizontal accuracy estimate in mm
 *      @tableEntry {blob} vAcc - 4 byte unsigened integer, Vertical accuracy estimate in mm
 *      @tableEntry {integer} velN - NED north velocity in mm/s
 *      @tableEntry {integer} velE - NED east velocity in mm/s
 *      @tableEntry {integer} velD - NED down velocity in mm/s
 *      @tableEntry {integer} gSpeed - Ground Speed (2-D) in mm/s
 *      @tableEntry {integer} headMot - Heading of motion (2-D) in deg
 *      @tableEntry {blob} sAcc - 4 byte unsigened integer, Speed accuracy estimate in mm/s
 *      @tableEntry {blob} headAcc - 4 byte unsigened integer, Heading accuracy estimate (both
 *              motion and vehicle) in mm/s
 *      @tableEntry {integer} pDOP - Position DOP
 *      @tableEntry {integer} headVeh - Heading of vehicle (2-D) in deg
 *      @tableEntry {integer} magDec - Magnetic declination in deg
 *      @tableEntry {integer} magAcc - Magnetic declination accuracy in deg
 */
UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.NAV_PVT] <- function(payload) {
    // 0x0107: Expected payload size = 92 Bytes
    payload.seek(0, 'b');
    local iTOW = payload.readblob(4);
    local year = payload.readn('w');
    local valid = payload[11];
    valid = {
        "validDate"     : (valid & 0x01) ? true : false,
        "validTime"     : (valid & 0x02) ? true : false,
        "fullyResolved" : (valid & 0x04) ? true : false,
        "validMag"      : (valid & 0x08) ? true : false
    };
    payload.seek(12, 'b');
    local tAcc = payload.readblob(4);
    local nano = payload.readn('i');
    local f1 = payload[21];
    local f2 = payload[22];
    local fixStatusFlags = {
        "gnssFixOK" : f1 & 0x01,
        "diffSoln" : (f1 & 0x02) >> 1,
        "psmState" : (f1 & 0x1C) >> 2,
        "headVehValid" : (f1 & 0x20) >> 5,
        "carrSoln" : (f1 & 0xC0) >> 6,
        "confirmedAvai" : (f2 & 0x20) >> 5,
        "confirmedDate" : (f2 & 0x40) >> 6,
        "confirmedTime" : (f2 & 0x80) >> 7
    };
    payload.seek(24, 'b');
    local lon = payload.readn('i');
    local lat = payload.readn('i');
    local height = payload.readn('i');
    local hMSL = payload.readn('i');
    local hAcc = payload.readblob(4);
    local vAcc = payload.readblob(4);
    local velN = payload.readn('i');
    local velE = payload.readn('i');
    local velD = payload.readn('i');
    local gSpeed = payload.readn('i');
    local headMot = payload.readn('i');
    local sAcc = payload.readblob(4);
    local headAcc = payload.readblob(4);
    local pDOP = payload.readn('w');
    payload.seek(84, 'b');
    local headVeh = payload.readn('i');
    local magDec = payload.readn('s');
    local magAcc = payload.readn('w');

    return {
        "iTOW"           : iTOW,            // GPS time of week in ms
        "year"           : year,            // Year (UTC)
        "month"          : payload[6],      // Month (UTC)
        "day"            : payload[7],      // Day (UTC)
        "hour"           : payload[8],      // Hour (UTC)
        "min"            : payload[9],      // Min (UTC)
        "sec"            : payload[10],     // Sec (UTC)
        "valid"          : valid,
        "tAcc"           : tAcc,            // Time Accuracy estimate (UTC)
        "nano"           : nano,            // Nanoseconds (UTC)
        "fixType"        : payload[20],     // Fix Type (see enum UBX_MSG_PARSER_FIX_TYPE)
        "fixStatusFlags" : fixStatusFlags,
        "numSV"          : payload[23],     // Num Satelites used in Nav Solution
        "lon"            : lon,             // Longitude (deg)
        "lat"            : lat,             // Latitude (deg)
        "height"         : height,          // Height above Ellipsoid (mm)
        "hMSL"           : hMSL,            // Height above mean sea level (mm)
        "hAcc"           : hAcc,            // Horizontal accuracy estimate (mm)
        "vAcc"           : vAcc,            // Vertical accuracy estimate (mm)
        "velN"           : velN,            // NED north velocity (mm/s)
        "velE"           : velE,            // NED east velocity (mm/s)
        "velD"           : velD,            // NED down velocity (mm/s)
        "gSpeed"         : gSpeed,          // Ground Speed 2-D (mm/s)
        "headMot"        : headMot,         // Heading of motion 2-D (deg)
        "sAcc"           : sAcc,            // Speed accuracy estimate (mm/s)
        "headAcc"        : headAcc,         // Heading accuracy estimate, both motion and vehicle (deg)
        "pDOP"           : pDOP,            // Position DOP
        "headVeh"        : headVeh,         // Heading of vehicle 2-D (deg)
        "magDec"         : magDec,          // Magnetic declination (deg)
        "magAcc"         : magAcc,          // Magnetic declination accuracy (deg)
    };
};

/**
 * Parses 0x0135 (NAV_SAT) UBX message payload.
 *
 * @param {blob} payload - parses 8 + 12*n bytes NAV_SAT message payload.
 *
 * @return {table}
 *      @tableEntry {blob} iTOW - 4 byte unsigened integer, GPS time of week of the navigation epoch in ms.
 *      @tableEntry {integer} version - Message version (1 for this version)
 *      @tableEntry {integer} numSvs - Number of satellites
 *      @tableEntry {object[]} satInfo - Array of satelite info tables
 *              {table} - Satelite info
 *                  @tableEntry {integer} gnssId - GNSS identifier
 *                  @tableEntry {integer} svId - Satellite identifier
 *                  @tableEntry {integer} cno - Carrier to noise ratio (signal strength) in dBHz
 *                  @tableEntry {integer} elev - Elevation (range: +/-90), unknown if out of range, in deg
 *                  @tableEntry {integer} azim - Azimuth (range 0-360), unknown if elevation is out of range, in deg
 *                  @tableEntry {integer} prRes - Pseudorange residual in m
 *                  @tableEntry {table} flags - table of flags
 *                      @tableEntry {integer} qualityInd - Signal quality indicator: 0 = no signal, 1 = searching
 *                          signal, 2 = signal acquired, 3 = signal detected but unusable, 4 = code locked and
 *                          time synchronized, 5, 6, 7 = code and carrier locked and time synchronized
 *                      @tableEntry {integer} svUsed - 1 = Signal in the subset specified in Signal Identifiers is
 *                          currently being used for navigation
 *                      @tableEntry {integer} health - Signal health flag: 0 = unknown, 1 = healthy, 2 = unhealthy
 *                      @tableEntry {integer} diffCorr - 1 = differential correction data is available for this SV
 *                      @tableEntry {integer} smoothed - 1 = carrier smoothed pseudorange used
 *                      @tableEntry {integer} orbitSource - Orbit source: 0 = no orbit information is available for
 *                          this SV, 1 = ephemeris is used, 2 = almanac is used, 3: AssistNow Offline orbit is used,
 *                          4 = AssistNow Autonomous orbit is used, 5, 6, 7: other orbit information is used
 *                      @tableEntry {integer} ephAvail - 1 = ephemeris is available for this SV
 *                      @tableEntry {integer} almAvail - 1 = almanac is available for this SV
 *                      @tableEntry {integer} anoAvail - 1 = AssistNow Offline data is available for this SV
 *                      @tableEntry {integer} aopAvail - 1 = AssistNow Autonomous data is available for this SV
 *                      @tableEntry {integer} sbasCorrUsed - 1 = SBAS corrections have been used for a signal
 *                      @tableEntry {integer} rtcmCorrUsed - 1 = RTCM corrections have been used
 *                      @tableEntry {integer} slasCorrUsed - 1 = QZSS SLAS corrections have been used
 *                      @tableEntry {integer} prCorrUsed - 1 = Pseudorange corrections have been used
 *                      @tableEntry {integer} crCorrUsed - 1 = Carrier range corrections have been used
 *                      @tableEntry {integer} doCorrUsed - 1 = Range rate (Doppler) corrections have been used
 */
UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.NAV_SAT] <- function(payload) {
    // 0x0135: Expected payload size = 8 + 12*n bytes
    payload.seek(0, 'b');
    local iTOW = payload.readblob(4);
    local parsed = {
        "iTOW"    : iTOW,            // GPS time of week in ms
        "version" : payload[4],      // Message version
        "numSvs"  : payload[5],      // Number of satellites
        "satInfo" : []               // Array of tables with sat info
    }

    // Satelite data start idx
    local idx = 8;
    // Number of complete satelite info packets received
    local numSat = (payload.len() - idx) / 12;

    for (local i = 0; i < numSat; i++) {
        payload.seek(idx, 'b');
        local info = {
            "gnssId" : payload.readn('b'),  // GNSS identifier
            "svId"   : payload.readn('b'),  // Satellite identifier
            "cno"    : payload.readn('b'),  // Carrier to noise ratio, signal strength (dBHz)
            "elev"   : payload.readn('c'),  // Elevation (range: +/-90), unknown if out of range (deg)
            "azim"   : payload.readn('s'),  // Azimuth (range 0-360), unknown if elevation is out of range
            "prRes"  : payload.readn('s'),  // Pseudorange residual
        }
        local flags = payload.readn('i'); // Read flag bits
        info.flags <- {
            "qualityInd"    : flags & 0x00000007,
            "svUsed"        : flags & 0x00000008 >> 3,
            "health"        : flags & 0x00000030 >> 4,
            "diffCorr"      : flags & 0x00000040 >> 6,
            "smoothed"      : flags & 0x00000080 >> 7,
            "orbitSource"   : flags & 0x00000700 >> 8,
            "ephAvail"      : flags & 0x00000800 >> 11,
            "almAvail"      : flags & 0x00001000 >> 12,
            "anoAvail"      : flags & 0x00002000 >> 13,
            "aopAvail"      : flags & 0x00004000 >> 14,
            "sbasCorrUsed"  : flags & 0x00010000 >> 16,
            "rtcmCorrUsed"  : flags & 0x00020000 >> 17,
            "slasCorrUsed"  : flags & 0x00040000 >> 18,
            "prCorrUsed"    : flags & 0x00100000 >> 20,
            "crCorrUsed"    : flags & 0x00200000 >> 21,
            "doCorrUsed"    : flags & 0x00400000 >> 22
        }

        parsed.satInfo.push(info);
        idx += 12;
    }

    return parsed;
};

/**
 * Parses 0x0501 (ACK_ACK) UBX message payload.
 *
 * @param {blob} payload - parses 2 byte ACK_ACK message payload.
 *
 * @return {integer} The 2 byte message class and ID for the ACK-ed message
 */
UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.ACK_ACK] <- function(payload) {
    // 0x0501: Expected payload size = 2 bytes
    // Returns classid of ACK-ed msg
    return payload[0] << 4 | payload[1];
};

/**
 * Parses 0x0500 (ACK_NAK) UBX message payload.
 *
 * @param {blob} payload - parses 2 byte ACK_NAK message payload.
 *
 * @return {integer} The 2 byte message class and ID for the NAK-ed message
 */
UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.ACK_NAK] <- function(payload) {
    // 0x0500: Expected payload size = 2 bytes
    // Returns classid of NAK-ed msg
    return payload[0] << 4 | payload[1];
};

/**
 * Parses 0x0a04 (MON_VER) UBX message payload.
 *
 * @param {blob} payload - parses 40 + 30*n bytes MON_VER message payload.
 *
 * @return {table}
 *      @tableEntry {string} swVersion - Software Version.
 *      @tableEntry {string} hwVersion - Hardware Version
 *      @tableEntry {object[]} [exSwInfo] - Array of extended software info strings, if any
 */
UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.MON_VER] <- function(payload) {
    // 40 + 30*n bytes
    payload.seek(0, 'b');
    local sw = payload.readstring(30);
    local last = sw.find("\x00");
    sw = sw.slice(0, last));

    local hw = payload.readstring(10);
    last = hw.find("\x00");
    hw = hw.slice(0, last));

    local parsed = {
        "swVersion" : sw,
        "hwVersion" : hw
    }

    // Add extended software information strings
    local exSwInfo = [];
    while (payload.eos() == null) {
        local info = payload.readstring(30);
        last = info.find("\x00");
        exSwInfo.push(info.slice(0, last));
    }
    if (exSwInfo.len() > 0) parsed.exSwInfo <- exSwInfo;

    return parsed;
};

/**
 * Parses 0x0a09 (MON_HW) UBX message payload.
 *
 * @param {blob} payload - parses 60 bytes MON_HW message payload.
 *
 * @return {table}
 *      @tableEntry {blob} pinSel - Mask of Pins Set as Peripheral/PIO
 *      @tableEntry {blob} pinBank - Mask of Pins Set as Bank A/B
 *      @tableEntry {blob} pinDir - Mask of Pins Set as Input/Output
 *      @tableEntry {blob} pinVal - Mask of Pins Value Low/High
 *      @tableEntry {integer} noisePerMS - Noise Level as measured by the GPS Core
 *      @tableEntry {integer} agcCnt - AGC Monitor (counts SIGHI xor SIGLO, range 0 to 8191)
 *      @tableEntry {integer} aStatus - Status of the Antenna Supervisor State Machine:
 *          0 = INIT, 1 = DONTKNOW, 2 = OK, 3 = SHORT, 4 = OPEN
 *      @tableEntry {integer} aPower - Current PowerStatus of Antenna: 0 = OFF, 1 = ON,
 *          2 = DON'T KNOW
 *      @tableEntry {table} flags -
 *              @tableEntry {integer} rtcCalib - RTC is calibrated
 *              @tableEntry {integer} safeBoot - safeBoot mode: 0 = inactive, 1 = active
 *              @tableEntry {integer} jammingState - output from Jamming/Interference Monitor:
 *                  0 = unknown or feature disabled, 1 = ok - no significant jamming,
 *                  2 = warning - interference visible but fix OK,
 *                  3 = critical - interference visible and no fix
 *              @tableEntry {integer} xtalAbsent - RTC xtal has been determined to be absent.
 *                  (not supported in protocol versions less than 18)
 *      @tableEntry {blob} usedMask - Mask of Pins that are used by the Virtual Pin Manager
 *      @tableEntry {blob} vp - Array of Pin Mappings for each of the 17 Physical Pins
 *      @tableEntry {integer} jamInd - CW Jamming indicator, scaled: 0 = no CW jamming,
 *              255 = strong CW jamming
 *      @tableEntry {blob} pinIrq - Mask of Pins Value using the PIO Irq
 *      @tableEntry {blob} pullH - Mask of Pins Value using the PIO Pull High Resistor
 *      @tableEntry {blob} pullL - Mask of Pins Value using the PIO Pull Low Resistor
 */
UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.MON_HW] <- function(payload) {
    // 0x0a09: Expected payload size = 60 bytes
    payload.seek(0, 'b');
    local parsed = {
        "pinSel"     : payload.readblob(4),
        "pinBank"    : payload.readblob(4),
        "pinDir"     : payload.readblob(4),
        "pinVal"     : payload.readblob(4),
        "noisePerMS" : payload.readn('w'),
        "agcCnt"     : payload.readn('w'),
        "aStatus"    : payload.readn('b'),
        "aPower"     : payload.readn('b')
    };
    local flags = payload.readn('b');
    parsed.flags <- {
        "rtcCalib"     : flags & 0x01,
        "safeBoot"     : flags & 0x02 >> 1,
        "jammingState" : flags & 0x0C >> 2,
        "xtalAbsent"   : flags & 0x10 >> 4
    }
    payload.seek(24, 'b');
    parsed.usedMask <- payload.readblob(4);
    parsed.vp <- payload.readblob(17);
    parsed.jamInd <- payload.readn('b');
    payload.seek(48, 'b');
    parsed.pinIrq <- payload.readblob(4);
    parsed.pullH <- payload.readblob(4);
    parsed.pullL <- payload.readblob(4);

    return parsed;
};

/**
 * Parses 0x1360 (MGA_ACK) UBX message payload.
 *
 * @param {blob} payload - parses 8 bytes bytes MGA_ACK message payload.
 *
 * @return {table}
 *      @tableEntry {integer} type - Type of acknowledgment: 0 = The message was not
 *          used by the receiver (see infoCode field for an indication of why), 1 = The
 *          message was accepted for use by the receiver (the infoCode field will be 0)
 *      @tableEntry {integer} version - Message version (0x00 for this version)
 *      @tableEntry {integer} infoCode - Provides greater information on what the
 *          receiver chose to do with the message contents: 0 = The receiver accepted
 *          the data, 1 = The receiver doesn't know the time so can't use the data
 *          (To resolve this a UBX-MGA-INITIME_UTC message should be supplied first),
 *          2 = The message version is not supported by the receiver, 3 = The message
 *          size does not match the message version, 4 = The message data could not be
 *          stored to the database, 5 = The receiver is not ready to use the message
 *          data, 6 = The message type is unknown
 *      @tableEntry {integer} msgId - UBX message ID of the ack'ed message
 *      @tableEntry {blob} msgPayloadStart - The first 4 bytes of the ack'ed message's
 *          payload
 */
UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.MGA_ACK] <- function(payload) {
    // 0x1360: Expected payload size = 8 bytes
    payload.seek(0, 'b');
    return {
        "type"            : payload.readn('b'),
        "version"         : payload.readn('b'),
        "infoCode"        : payload.readn('b'),
        "msgId"           : payload.readn('b'),
        "msgPayloadStart" : payload.readblob(4)
    }
};
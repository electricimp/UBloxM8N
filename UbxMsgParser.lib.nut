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
 * payload conatins a 32 bit unsigned integer the parsed table will contain a 4 byte
 * blob with the payload values. These values are in the same order as received
 * by the M8N (little endian).
 *
 * @table
 */
UbxMsgParser <- {
    "VERSION" : "1.0.0",
    "ERROR_UNEXPECTED_PAYLOAD_LEN" : "Error: Expected payload length %i, received payload with length %i",
    "_getLenError" : function(payload, expected, expectedMin = null) {
        local actual = payload.len();
        local check = (expected == null) ? (actual >= expectedMin) : (actual == expected);
        if (check) {
            return null;
        } else {
            return {
                "error" : format(ERROR_UNEXPECTED_PAYLOAD_LEN, expected, actual),
                "payload" : payload
            };
        }
    },
}

/**
 * @typedef {table} UBX_NAV_PVT::ValidityFlags
 * @property {bool} validDate - valid UTC Date
 * @property {bool} validTime - valid UTC Time of Day
 * @property {bool} fullyResolved - UTC Time of Day has been fully resolved (no seconds uncertainty)
 * @property {bool} validMag - valid Magnetic declination
 */

/**
 * @typedef {table} UBX_NAV_PVT::fixStatusFlags
 * @property {integer} gnssFixOK - 1 = valid fix (i.e within DOP & accuracy masks)
 * @property {integer} diffSoln - 1 = differential corrections were applied
 * @property {integer} psmState - Power Save Mode state: 0 = PSM is not active,
 *   1 = Enabled (an intermediate state before Acquisition state), 2 = Acquisition,
 *   3 = Tracking, 4 = Power Optimized Tracking, 5 = Inactive
 * @property {integer} headVehValid - 1 = heading of vehicle is valid
 * @property {integer} carrSoln - Carrier phase range solution status (not supported in
 *   protocol versions less than 20): 0: no carrier phase range solution, 1 = float
 *   solution (no fixed integer carrier phase measurements have been used to calculate
 *   the solution), 2 = fixed solution (one or more fixed integer carrier phase range
 *   measurements have been used to calculate the solution)
 * @property {integer} confirmedAvai - (Not supported in all versions) 1 = information
 *   about UTC Date and Time of Day validity confirmation is available
 * @property {integer} confirmedDate - 1 = UTC Date validity could be confirmed
 * @property {integer} confirmedTime - 1 = UTC Time of Day could be confirmed
 */

/**
 * @typedef {table} UBX_NAV_PVT
 * @property {blob} iTOW - 4 byte unsigened integer, GPS time of week of the navigation epoch in ms.
 * @property {integer} year - Year (UTC)
 * @property {integer} month - Month, range 1..12 (UTC)
 * @property {integer} day - Day of month, range 1..31 (UTC)
 * @property {integer} hour - Hour of day, range 0..23 (UTC)
 * @property {integer} min - Minute of hour, range 0..59 (UTC)
 * @property {integer} sec - Seconds of minute, range 0..60 (UTC)
 * @property {UBX_NAV_PVT::ValidityFlags} valid - Validity flags
 * @property {integer} tAcc - Time accuracy estimate in ns (UTC)
 * @property {integer} nano - Fraction of second, range -1e9 .. 1e9 in ns (UTC)
 * @property {integer} fixType - GNSSfix Type: 0 = no fix, 1 = dead reckoning only,
 *   2 = 2D-fix, 3 = 3D-fix, 4 = GNSS + dead reckoning combined, 5 = time only fix
 * @property {UBX_NAV_PVT::fixStatusFlags} fixStatusFlags - Fix status flags table
 * @property {integer} numSV - Number of satellites used in Nav Solution
 * @property {integer} lon - Longitude in deg
 * @property {integer} lat - Latitude in deg
 * @property {integer} height - Height above ellipsoid in mm
 * @property {integer} hMSL - Height above mean sea level mm
 * @property {blob} hAcc - 4 byte unsigened integer, Horizontal accuracy estimate in mm
 * @property {blob} vAcc - 4 byte unsigened integer, Vertical accuracy estimate in mm
 * @property {integer} velN - NED north velocity in mm/s
 * @property {integer} velE - NED east velocity in mm/s
 * @property {integer} velD - NED down velocity in mm/s
 * @property {integer} gSpeed - Ground Speed (2-D) in mm/s
 * @property {integer} headMot - Heading of motion (2-D) in deg
 * @property {blob} sAcc - 4 byte unsigened integer, Speed accuracy estimate in mm/s
 * @property {blob} headAcc - 4 byte unsigened integer, Heading accuracy estimate (both
 *   motion and vehicle) in mm/s
 * @property {integer} pDOP - Position DOP
 * @property {integer} headVeh - Heading of vehicle (2-D) in deg
 * @property {integer} magDec - Magnetic declination in deg
 * @property {integer} magAcc - Magnetic declination accuracy in deg
 */

/**
 * Parses 0x0107 (NAV_PVT) UBX message payload.
 *
 * @param {blob} payload - parses 100 byte NAV_PVT message payload.
 *
 * @return {UBX_NAV_PVT}
 */
UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.NAV_PVT] <- function(payload) {
    // 0x0107: Expected payload size = 92 Bytes
    local expectedLen = 92;
    local err = _getLenError(payload, expectedLen);
    if (err != null) return err;

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
        "fixType"        : payload[20],     // Fix Type (see docs)
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
 * @typedef {table} UBX_NAV_SAT::satInfo
 * @property {integer} gnssId - GNSS identifier
 * @property {integer} svId - Satellite identifier
 * @property {integer} cno - Carrier to noise ratio (signal strength) in dBHz
 * @property {integer} elev - Elevation (range: +/-90), unknown if out of range, in deg
 * @property {integer} azim - Azimuth (range 0-360), unknown if elevation is out of range, in deg
 * @property {integer} prRes - Pseudorange residual in m
 */

/**
 * @typedef {table} UBX_NAV_SAT::satInfo::flags
 * @property {integer} qualityInd - Signal quality indicator: 0 = no signal, 1 = searching
 *     signal, 2 = signal acquired, 3 = signal detected but unusable, 4 = code locked and
 *     time synchronized, 5, 6, 7 = code and carrier locked and time synchronized
 * @property {integer} svUsed - 1 = Signal in the subset specified in Signal Identifiers is
 *     currently being used for navigation
 * @property {integer} health - Signal health flag: 0 = unknown, 1 = healthy, 2 = unhealthy
 * @property {integer} diffCorr - 1 = differential correction data is available for this SV
 * @property {integer} smoothed - 1 = carrier smoothed pseudorange used
 * @property {integer} orbitSource - Orbit source: 0 = no orbit information is available for
 *     this SV, 1 = ephemeris is used, 2 = almanac is used, 3: AssistNow Offline orbit is used,
 *     4 = AssistNow Autonomous orbit is used, 5, 6, 7: other orbit information is used
 * @property {integer} ephAvail - 1 = ephemeris is available for this SV
 * @property {integer} almAvail - 1 = almanac is available for this SV
 * @property {integer} anoAvail - 1 = AssistNow Offline data is available for this SV
 * @property {integer} aopAvail - 1 = AssistNow Autonomous data is available for this SV
 * @property {integer} sbasCorrUsed - 1 = SBAS corrections have been used for a signal
 * @property {integer} rtcmCorrUsed - 1 = RTCM corrections have been used
 * @property {integer} slasCorrUsed - 1 = QZSS SLAS corrections have been used
 * @property {integer} prCorrUsed - 1 = Pseudorange corrections have been used
 * @property {integer} crCorrUsed - 1 = Carrier range corrections have been used
 * @property {integer} doCorrUsed - 1 = Range rate (Doppler) corrections have been used
 */

/**
 * @typedef {table} UBX_NAV_SAT
 * @property {blob} iTOW - 4 byte unsigened integer, GPS time of week of the navigation epoch in ms.
 * @property {integer} version - Message version (1 for this version)
 * @property {integer} numSvs - Number of satellites
 * @property {satInfo[]} satInfo - Array of satInfo tables
 */

/**
 * Parses 0x0135 (NAV_SAT) UBX message payload.
 *
 * @param {blob} payload - parses 8 + 12*n bytes NAV_SAT message payload.
 *
 * @return {UBX_NAV_SAT}
 */
UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.NAV_SAT] <- function(payload) {
    // 0x0135: Expected payload size = 8 + 12*n bytes
    local expectedMin = 8;
    local err = _getLenError(payload, null, expectedMin);
    if (err != null) return err;

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
    local expected = 2;
    local err = _getLenError(payload, expected);
    if (err != null) return err;

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
    local expected = 2;
    local err = _getLenError(payload, expected);
    if (err != null) return err;

    // Returns classid of NAK-ed msg
    return payload[0] << 4 | payload[1];
};

/**
 * @typedef {table} UBX_MON_VER
 * @property {string} swVersion - Software Version
 * @property {string} hwVersion - Hardware Version
 * @property {string} protver - Supported protocol version
 * @property {strings[]} [exSwInfo] - Array of strings with extended software info, if any
 */

/**
 * Parses 0x0a04 (MON_VER) UBX message payload.
 *
 * @param {blob} payload - parses 40 + 30*n bytes MON_VER message payload.
 *
 * @return {UBX_MON_VER}
 */
UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.MON_VER] <- function(payload) {
    // 0x0a04: Expected payload size = 40 + 30*n bytes
    local expectedMin = 40;
    local err = _getLenError(payload, null, expectedMin);
    if (err != null) return err;

    payload.seek(0, 'b');
    local sw = payload.readstring(30);
    local last = sw.find("\x00");
    sw = sw.slice(0, last);

    local hw = payload.readstring(10);
    last = hw.find("\x00");
    hw = hw.slice(0, last);

    local parsed = {
        "swVersion" : sw,
        "hwVersion" : hw
    }

    // Add extended software information strings
    local exSwInfo = [];
    while (payload.eos() == null) {
        local info = payload.readstring(30);
        last = info.find("\x00");
        local str = info.slice(0, last);
        exSwInfo.push(str);
        if (info.find("PROTVER") != null) {
            local ex = regexp(@"(\d+)[.](\d+)");
            local match = ex.search(info);
            if (match != null) {
                parsed.protver <- info.slice(match.begin, match.end);
            }
        }
    }
    if (exSwInfo.len() > 0) parsed.exSwInfo <- exSwInfo;

    return parsed;
};

/**
 * @typedef {table} UBX_MON_HW::flags
 * @property {integer} rtcCalib - RTC is calibrated
 * @property {integer} safeBoot - safeBoot mode: 0 = inactive, 1 = active
 * @property {integer} jammingState - output from Jamming/Interference Monitor:
 *      0 = unknown or feature disabled, 1 = ok - no significant jamming,
 *      2 = warning - interference visible but fix OK,
 *      3 = critical - interference visible and no fix
 * @property {integer} xtalAbsent - RTC xtal has been determined to be absent.
 *      (not supported in protocol versions less than 18)
 */

/**
 * @typedef {table} UBX_MON_HW
 * @property {blob} pinSel - Mask of Pins Set as Peripheral/PIO
 * @property {blob} pinBank - Mask of Pins Set as Bank A/B
 * @property {blob} pinDir - Mask of Pins Set as Input/Output
 * @property {blob} pinVal - Mask of Pins Value Low/High
 * @property {integer} noisePerMS - Noise Level as measured by the GPS Core
 * @property {integer} agcCnt - AGC Monitor (counts SIGHI xor SIGLO, range 0 to 8191)
 * @property {integer} aStatus - Status of the Antenna Supervisor State Machine:
 *      0 = INIT, 1 = DONTKNOW, 2 = OK, 3 = SHORT, 4 = OPEN
 * @property {integer} aPower - Current PowerStatus of Antenna: 0 = OFF, 1 = ON, 2 = DON'T KNOW
 * @property {UBX_MON_HW::flags} flags - table of flags
 * @property {blob} usedMask - Mask of Pins that are used by the Virtual Pin Manager
 * @property {blob} vp - Array of Pin Mappings for each of the 17 Physical Pins
 * @property {integer} jamInd - CW Jamming indicator, scaled: 0 = no CW jamming, 255 = strong CW jamming
 * @property {blob} pinIrq - Mask of Pins Value using the PIO Irq
 * @property {blob} pullH - Mask of Pins Value using the PIO Pull High Resistor
 * @property {blob} pullL - Mask of Pins Value using the PIO Pull Low Resistor
 */

/**
 * Parses 0x0a09 (MON_HW) UBX message payload.
 *
 * @param {blob} payload - parses 60 bytes MON_HW message payload.
 *
 * @return {UBX_MON_HW}
 */
UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.MON_HW] <- function(payload) {
    // 0x0a09: Expected payload size = 60 bytes
    local expected = 60;
    local err = _getLenError(payload, expected);
    if (err != null) return err;

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
 * @typedef {table} UBX_MGA_ACK
 * @property {integer} type - Type of acknowledgment: 0 = The message was not
 *      used by the receiver (see infoCode field for an indication of why), 1 = The
 *      message was accepted for use by the receiver (the infoCode field will be 0)
 * @property {integer} version - Message version (0x00 for this version)
 * @property {integer} infoCode - Provides greater information on what the
 *      receiver chose to do with the message contents: 0 = The receiver accepted
 *      the data, 1 = The receiver doesn't know the time so can't use the data
 *      (To resolve this a UBX-MGA-INITIME_UTC message should be supplied first),
 *      2 = The message version is not supported by the receiver, 3 = The message
 *      size does not match the message version, 4 = The message data could not be
 *      stored to the database, 5 = The receiver is not ready to use the message
 *      data, 6 = The message type is unknown
 * @property {integer} msgId - UBX message ID of the ack'ed message
 * @property {blob} msgPayloadStart - The first 4 bytes of the ack'ed message's payload
 */

/**
 * Parses 0x1360 (MGA_ACK) UBX message payload.
 *
 * @param {blob} payload - parses 8 bytes bytes MGA_ACK message payload.
 *
 * @return {UBX_MGA_ACK}
 */
UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.MGA_ACK] <- function(payload) {
    // 0x1360: Expected payload size = 8 bytes
    local expected = 8;
    local err = _getLenError(payload, expected);
    if (err != null) return err;

    payload.seek(0, 'b');
    // TODO: here and everywhere else probably it makes sense to check for length before we read
    return {
        "type"            : payload.readn('b'),
        "version"         : payload.readn('b'),
        "infoCode"        : payload.readn('b'),
        "msgId"           : payload.readn('b'),
        "msgPayloadStart" : payload.readblob(4)
    }
};
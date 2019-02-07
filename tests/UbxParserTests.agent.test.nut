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

@include __PATH__+"/../Parser/UbxMsgParser.lib.nut"

enum UBX_VALID_MSG {
    NAV_PVT = "\xd0\x09\xb7\x19\xe3\x07\x01\x18\x17\x32\x08\xf7\xf7\x03\x00\x00\xa6\x6c\x02\x00\x03\x01\x0a\x0b\x44\xaa\x38\xb7\xfb\x1a\x4a\x16\x4b\x5a\x00\x00\x8a\xcf\x00\x00\x2a\x18\x00\x00\xd7\x10\x00\x00\xf9\xff\xff\xff\xf9\xff\xff\xff\xfd\xff\xff\xff\x0a\x00\x00\x00\x00\x00\x00\x00\x61\x01\x00\x00\x14\x6e\x01\x01\x9a\x00\x00\xe0\x86\x4c\x22\x00\x00\x00\x02\x00\x00\x00\x00\x80",
    NAV_SAT_LONG = "\x30\xf4\xb7\x19\x01\x17\x00\x00\x00\x05\x0c\x15\x1c\x01\x63\x00\x1c\x19\x00\x00\x00\x07\x30\x3e\x32\x00\xef\xff\x1f\x19\x00\x00\x00\x08\x25\x23\x3f\x00\xfd\xff\x1f\x09\x00\x00\x00\x0b\x00\x10\x75\x00\x00\x00\x11\x09\x00\x00\x00\x0d\x1f\x0c\x3d\x01\x6a\xff\x1e\x09\x00\x00\x00\x17\x19\x0d\x93\x00\x75\x00\x1c\x19\x00\x00\x00\x1b\x22\x0e\x28\x00\xfa\xff\x1f\x19\x00\x00\x00\x1c\x00\x36\xec\x00\x00\x00\x11\x12\x00\x00\x00\x1e\x2c\x3e\x46\x01\x0a\x00\x1f\x19\x00\x00\x01\x85\x00\x28\x90\x00\x00\x00\x01\x07\x00\x00\x01\x87\x00\x2d\xc6\x00\x00\x00\x01\x07\x00\x00\x01\x8a\x00\x2c\x9c\x00\x00\x00\x01\x07\x00\x00\x05\x01\x00\xa5\x00\x00\x00\x00\x01\x00\x00\x00\x05\x04\x00\xa5\x00\x00\x00\x00\x01\x00\x00\x00\x05\x05\x00\xa5\x00\x00\x00\x00\x01\x00\x00\x00\x06\x01\x00\x0e\xb8\x00\x00\x00\x11\x12\x00\x00\x06\x02\x15\x37\xf4\x00\x00\x00\x14\x12\x00\x00\x06\x03\x21\x20\x3e\x01\xc1\xff\x1f\x19\x00\x00\x06\x0b\x27\x19\x35\x00\x21\x00\x1f\x19\x00\x00\x06\x0c\x21\x36\x05\x00\x55\x00\x1f\x19\x00\x00\x06\x0d\x0b\x1c\x19\x01\x00\x00\x14\x12\x00\x00\x06\x15\x1d\x17\x38\x00\x1b\x00\x1e\x19\x00\x00\x06\x16\x1a\x16\x75\x00\x00\x00\x16\x12\x00\x00"
    NAV_SAT_SHORT = "\xe8\x03\x00\x00\x01\x00\x00\x00",
    ACK_ACK = "\x06\x01",
    ACK_NAK = "\x06\x01",
    MON_HW  = "\x00\xf4\x01\x00\x00\x00\x00\x00\x00\x00\x01\x00\xef\xf7\x00\x00\x6c\x00\x00\x00\x00\x01\x00\x84\xff\xeb\x01\x00\x0a\x0b\x0c\x0d\x0e\x0f\x01\x00\x02\x03\xff\x10\xff\x12\x13\x36\x35\x00\x0f\x5e\x00\x00\x00\x00\x80\xf7\x00\x00\x00\x00\x00\x00",
    MON_VER = "\x32\x2e\x30\x31\x20\x28\x37\x35\x33\x33\x31\x29\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x30\x30\x30\x38\x30\x30\x30\x30\x00\x00\x50\x52\x4f\x54\x56\x45\x52\x20\x31\x35\x2e\x30\x30\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x47\x50\x53\x3b\x53\x42\x41\x53\x3b\x47\x4c\x4f\x3b\x42\x44\x53\x3b\x51\x5a\x53\x53\x00\x00\x00\x00\x00\x00\x00\x00\x00",
    MON_VER_NO_EX = "\x32\x2e\x30\x31\x20\x28\x37\x35\x33\x33\x31\x29\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x30\x30\x30\x38\x30\x30\x30\x30\x00\x00",
    MGA_ACK = "\x01\x00\x00\x06\x02\x00\x18\x00"
}

enum UBX_INVALID_MSG {
    NAV_PVT = "\xd0\x09\xb7\x19\xe3\x07",
    NAV_SAT = "\x06\x01",
    ACK_ACK = "a",
    ACK_NAK = "m",
    MON_HW  = "\x06\x01",
    MON_VER = "\x32\x2e\x30\x31\x20\x28\x37\x35\x33\x33\x31\x29\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x30\x30\x30\x38\x30\x30\x30\x30\x00\x00\x50",
    MGA_ACK = "z"
}

enum TEST_ERROR_MSG {
    PAYLOAD = "Parsed payload did not match original.",
    UNEXPECTED_FIELD_TYPE = "Unexpected %s field type.",
    UNEXPECTED_FIELD_VAL = "Unexpected %s field value.",
    ERROR_NOT_NULL = "Error was not null.",
    ERROR_MISSING = "No error message found."
}

class UbxParserTests extends ImpTestCase {

    function _createPayload(msg) {
        local b = blob(msg.len());
        b.writestring(msg);
        return b;
    }

    function _getExpectedSatFlags(b1, b2) {
        local flags = {
                "sbasCorrUsed"  : 0,
                "rtcmCorrUsed"  : 0,
                "slasCorrUsed"  : 0,
                "prCorrUsed"    : 0,
                "crCorrUsed"    : 0,
                "doCorrUsed"    : 0,
                "diffCorr"      : 0,
                "smoothed"      : 0,
                "anoAvail"      : 0,
                "aopAvail"      : 0
        }
        switch (b1 & 0x0F) {
            case 0x01:
                flags.qualityInd <- 1;
                flags.svUsed <- 0;
                break;
            case 0x04:
                flags.qualityInd <- 4;
                flags.svUsed <- 0;
                break;
            case 0x06:
                flags.qualityInd <- 6;
                flags.svUsed <- 0;
                break;
            case 0x0c:
                flags.qualityInd <- 4;
                flags.svUsed <- 1;
                break;
            case 0x0e:
                flags.qualityInd <- 6;
                flags.svUsed <- 1;
                break;
            case 0x0f:
                flags.qualityInd <- 7;
                flags.svUsed <- 1;
                break;
        }
        switch (b1 & 0xF0) {
            case 0x00:
                flags.health <- 0;
                break;
            case 0x10:
                flags.health <- 1;
                break;
        }
        switch (b2 & 0x0F) {
            case 0x00:
                flags.orbitSource <- 0;
                flags.ephAvail <- 0;
                break;
            case 0x02:
                flags.orbitSource <- 2;
                flags.ephAvail <- 0;
                break;
            case 0x07:
                flags.orbitSource <- 7;
                flags.ephAvail <- 0;
                break;
            case 0x09:
                flags.orbitSource <- 1;
                flags.ephAvail <- 1;
                break;
        }
        switch (b2 & 0xF0) {
            case 0x00:
                flags.almAvail <- 0;
                break;
            case 0x10:
                flags.almAvail <- 1;
                break;
        }
        return flags;
    }

    function setUp() {
        return "No setUp needed for this test";
    }

    function testToDecimalDegreeString() {
        local lat = 0x164a1afb;
        local lon = 0xb738aa44;
        local expLat = "37.3955323";
        local expLon = "-122.1023164";

        assertEqual(expLat, UbxMsgParser.toDecimalDegreeString(lat));
        assertEqual(expLon, UbxMsgParser.toDecimalDegreeString(lon));

        return "toDecimalDegreeString method returned expected values";
    }

    function testNavPvtValid() {
        // binary: d0 09 b7 19 e3 07 01 18 17 32 08 f7 f7 03 00 00 a6 6c 02 00 03 01 0a 0b 44 aa 38 b7 fb 1a 4a 16 4b 5a 00 00 8a cf 00 00 2a 18 00 00 d7 10 00 00 f9 ff ff ff f9 ff ff ff fd ff ff ff 0a 00 00 00 00 00 00 00 61 01 00 00 14 6e 01 01 9a 00 00 e0 86 4c 22 00 00 00 02 00 00 00 00 80
        // Tests all fields are present and are expected type & value
        local payload = _createPayload(UBX_VALID_MSG.NAV_PVT);
        local parsed = UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.NAV_PVT](payload);

        assertTrue(crypto.equals(payload, parsed.payload), TEST_ERROR_MSG.PAYLOAD);
        assertEqual(null, parsed.error, TEST_ERROR_MSG.ERROR_NOT_NULL);

        assertTrue("iTOW" in parsed && (typeof parsed.iTOW == "blob"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "iTOW"));
        assertTrue(crypto.equals("\xd0\x09\xb7\x19", parsed.iTOW), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "iTOW"));

        assertTrue("year" in parsed && typeof parsed.year == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "year"));
        assertEqual(2019, parsed.year, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "year"));

        assertTrue("month" in parsed && typeof parsed.month == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "month"));
        assertEqual(1, parsed.month, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "month"));

        assertTrue("day" in parsed && typeof parsed.day == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "day"));
        assertEqual(0x18, parsed.day, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "day"));

        assertTrue("hour" in parsed && typeof parsed.hour == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "hour"));
        assertEqual(0x17, parsed.hour, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "hour"));

        assertTrue("min" in parsed && typeof parsed.min == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "min"));
        assertEqual(0x32, parsed.min, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "min"));

        assertTrue("sec" in parsed && typeof parsed.sec == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "sec"));
        assertEqual(0x08, parsed.sec, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "sec"));

        assertTrue("valid" in parsed && typeof parsed.valid == "table", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "valid"));
        local valid = parsed.valid; // 0xf7
        assertTrue("validDate" in valid && valid.validDate, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "validDate"));
        assertTrue("validTime" in valid && valid.validTime, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "validTime"));
        assertTrue("fullyResolved" in valid && valid.fullyResolved, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "fullyResolved"));
        assertTrue("validMag" in valid && !valid.validMag, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "validMag"));

        assertTrue("tAcc" in parsed && typeof parsed.tAcc == "blob", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "tAcc"));
        assertTrue(crypto.equals("\xf7\x03\x00\x00", parsed.tAcc), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "tAcc"));

        assertTrue("nano" in parsed && typeof parsed.nano == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "nano"));
        assertEqual(0x00026ca6, parsed.nano, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "nano"));

        assertTrue("fixType" in parsed && typeof parsed.fixType == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "fixType"));
        assertEqual(0x03, parsed.fixType, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "fixType"));

        assertTrue("fixStatusFlags" in parsed && typeof parsed.fixStatusFlags == "table", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "fixStatusFlags"));
        local flags = parsed.fixStatusFlags; // 0x01 0x0a
        assertTrue("gnssFixOK" in flags && flags.gnssFixOK, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "gnssFixOK"));
        assertTrue("diffSoln" in flags && !flags.diffSoln, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "diffSoln"));
        assertTrue("psmState" in flags && flags.psmState == 0, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "psmState"));
        assertTrue("headVehValid" in flags && !flags.headVehValid, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "headVehValid"));
        assertTrue("carrSoln" in flags && flags.carrSoln == 0, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "carrSoln"));
        assertTrue("confirmedAvai" in flags && !flags.confirmedAvai, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "confirmedAvai"));
        assertTrue("confirmedDate" in flags && !flags.confirmedDate, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "confirmedDate"));
        assertTrue("confirmedTime" in flags && !flags.confirmedTime, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "confirmedTime"));

        assertTrue("numSV" in parsed && typeof parsed.numSV == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "numSV"));
        assertEqual(0x0b, parsed.numSV, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "numSV"));

        assertTrue("lon" in parsed && typeof parsed.lon == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "lon"));
        assertEqual(0xb738aa44, parsed.lon, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "lon"));

        assertTrue("lat" in parsed && typeof parsed.lat == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "lat"));
        assertEqual(0x164a1afb, parsed.lat, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "lat"));

        assertTrue("height" in parsed && typeof parsed.height == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "height"));
        assertEqual(0x00005a4b, parsed.height, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "height"));

        assertTrue("hMSL" in parsed && typeof parsed.hMSL == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "hMSL"));
        assertEqual(0x0000cf8a, parsed.hMSL, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "hMSL"));

        assertTrue("hAcc" in parsed && typeof parsed.hAcc == "blob", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "hAcc"));
        assertTrue(crypto.equals("\x2a\x18\x00\x00", parsed.hAcc), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "hAcc"));

        assertTrue("vAcc" in parsed && typeof parsed.vAcc == "blob", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "vAcc"));
        assertTrue(crypto.equals("\xd7\x10\x00\x00", parsed.vAcc), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "vAcc"));

        assertTrue("velN" in parsed && typeof parsed.velN == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "velN"));
        assertEqual(0xfffffff9, parsed.velN, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "velN"));

        assertTrue("velE" in parsed && typeof parsed.velE == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "velE"));
        assertEqual(0xfffffff9, parsed.velE, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "velE"));

        assertTrue("velD" in parsed && typeof parsed.velD == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "velD"));
        assertEqual(0xfffffffd, parsed.velD, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "velD"));

        assertTrue("gSpeed" in parsed && typeof parsed.gSpeed == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "gSpeed"));
        assertEqual(0x0000000a, parsed.gSpeed, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "gSpeed"));

        assertTrue("headMot" in parsed && typeof parsed.headMot == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "headMot"));
        assertEqual(0x00000000, parsed.headMot, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "headMot"));

        assertTrue("sAcc" in parsed && typeof parsed.sAcc == "blob", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "sAcc"));
        assertTrue(crypto.equals("\x61\x01\x00\x00", parsed.sAcc), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "sAcc"));

        assertTrue("headAcc" in parsed && typeof parsed.headAcc == "blob", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "headAcc"));
        assertTrue(crypto.equals("\x14\x6e\x01\x01", parsed.headAcc), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "headAcc"));

        assertTrue("pDOP" in parsed && typeof parsed.pDOP == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "pDOP"));
        assertEqual(0x009a, parsed.pDOP, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "pDOP"));

        assertTrue("headVeh" in parsed && typeof parsed.headVeh == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "headVeh"));
        assertEqual(0x00020000, parsed.headVeh, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "headVeh"));

        assertTrue("magDec" in parsed && typeof parsed.magDec == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "magDec"));
        assertEqual(0x0000, parsed.magDec, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "magDec"));

        assertTrue("magAcc" in parsed && typeof parsed.magAcc == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "magAcc"));
        assertEqual(0x8000, parsed.magAcc, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "magAcc"));

        return "Valid NAV-PVT message parse test passed.";
    }

    function testNavPvtInvalid() {
        local payload = _createPayload(UBX_INVALID_MSG.NAV_PVT);
        local parsed = UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.NAV_PVT](payload);
        local error = format(UbxMsgParser.ERROR_PARSING, "");

        assertTrue(crypto.equals(payload, parsed.payload), TEST_ERROR_MSG.PAYLOAD);
        assertTrue(parsed.error.find(error) != null, TEST_ERROR_MSG.ERROR_MISSING);

        return "Invalid NAV-PVT message returned expected error.";
    }

    function testNavSatShortValid() {
        // binary: e8 03 00 00 01 00 00 00
        // Tests all fields are present and are expected type & value
        local payload = _createPayload(UBX_VALID_MSG.NAV_SAT_SHORT);
        local parsed = UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.NAV_SAT](payload);

        assertTrue(crypto.equals(payload, parsed.payload), TEST_ERROR_MSG.PAYLOAD);
        assertEqual(null, parsed.error, TEST_ERROR_MSG.ERROR_NOT_NULL);

        assertTrue("iTOW" in parsed && (typeof parsed.iTOW == "blob"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "iTOW"));
        assertTrue(crypto.equals("\xe8\x03\x00\x00", parsed.iTOW), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "iTOW"));

        assertTrue("version" in parsed && typeof parsed.version == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "version"));
        assertEqual(0x01, parsed.version, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "version"));

        assertTrue("numSvs" in parsed && typeof parsed.numSvs == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "numSvs"));
        assertEqual(0, parsed.numSvs, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "numSvs"));

        assertTrue("satInfo" in parsed && typeof parsed.satInfo == "array", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "satInfo"));
        assertTrue(parsed.satInfo.len() == parsed.numSvs, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo"));

        return "Valid NAV-SAT message with no satInfo parse test passed.";
    }

    function testNavSatLongValid() {
        // binary: 30 f4 b7 19 01 17 00 00 + flags
        // Tests all fields are present and are expected type & value
        local payload = _createPayload(UBX_VALID_MSG.NAV_SAT_LONG);
        local parsed = UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.NAV_SAT](payload);

        assertTrue(crypto.equals(payload, parsed.payload), TEST_ERROR_MSG.PAYLOAD);
        assertEqual(null, parsed.error, TEST_ERROR_MSG.ERROR_NOT_NULL);

        assertTrue("iTOW" in parsed && (typeof parsed.iTOW == "blob"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "iTOW"));
        assertTrue(crypto.equals("\x30\xf4\xb7\x19", parsed.iTOW), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "iTOW"));

        assertTrue("version" in parsed && typeof parsed.version == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "version"));
        assertEqual(0x01, parsed.version, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "version"));

        assertTrue("numSvs" in parsed && typeof parsed.numSvs == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "numSvs"));
        assertEqual(0x17, parsed.numSvs, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "numSvs"));

        assertTrue("satInfo" in parsed && typeof parsed.satInfo == "array", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "satInfo"));
        assertTrue(parsed.satInfo.len() == parsed.numSvs, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo"));

        local expected = [
            {   // idx = 0
                // 00 05 0c 15 1c 01 63 00 1c 19 00 00
                "gnssId" : 0x00,
                "svId"   : 0x05,
                "cno"    : 0x0c,
                "elev"   : 0x15,    // signed int 8
                "azim"   : 0x011c,  // signed int 16
                "prRes"  : 0x0063,  // signed int 16
                "flags"  : _getExpectedSatFlags(0x1c, 0x19)
            },
            {   // idx = 1
                // 00 07 30 3e 32 00 ef ff 1f 19 00 00
                "gnssId" : 0x00,
                "svId"   : 0x07,
                "cno"    : 0x30,
                "elev"   : 0x3e,                 // signed int 8
                "azim"   : 0x0032,               // signed int 16
                "prRes"  : (0xffef << 16) >> 16, // signed int 16
                "flags"  : _getExpectedSatFlags(0x1f, 0x19)
            },
            {   // idx = 2
                // 00 08 25 23 3f 00 fd ff 1f 09 00 00
                "gnssId" : 0x00,
                "svId"   : 0x08,
                "cno"    : 0x25,
                "elev"   : 0x23,                 // signed int 8
                "azim"   : 0x003f,               // signed int 16
                "prRes"  : (0xfffd << 16) >> 16, // signed int 16
                "flags"  : _getExpectedSatFlags(0x1f, 0x09)
            },
            {   // idx = 3
                // 00 0b 00 10 75 00 00 00 11 09 00 00
                "gnssId" : 0x00,
                "svId"   : 0x0b,
                "cno"    : 0x00,
                "elev"   : 0x10,    // signed int 8
                "azim"   : 0x0075,  // signed int 16
                "prRes"  : 0x0000,  // signed int 16
                "flags"  : _getExpectedSatFlags(0x11, 0x09)
            },
            {   // idx = 4
                // 00 0d 1f 0c 3d 01 6a ff 1e 09 00 00
                "gnssId" : 0x00,
                "svId"   : 0x0d,
                "cno"    : 0x1f,
                "elev"   : 0x0c,                 // signed int 8
                "azim"   : 0x013d,               // signed int 16
                "prRes"  : (0xff6a << 16) >> 16, // signed int 16
                "flags"  : _getExpectedSatFlags(0x1e, 0x09)
            },
            {   // idx = 5
                // 00 17 19 0d 93 00 75 00 1c 19 00 00
                "gnssId" : 0x00,
                "svId"   : 0x17,
                "cno"    : 0x19,
                "elev"   : 0x0d,    // signed int 8
                "azim"   : 0x0093,  // signed int 16
                "prRes"  : 0x0075,  // signed int 16
                "flags"  : _getExpectedSatFlags(0x1c, 0x19)
            },
            {   // idx = 6
                // 00 1b 22 0e 28 00 fa ff 1f 19 00 00
                "gnssId" : 0x00,
                "svId"   : 0x1b,
                "cno"    : 0x22,
                "elev"   : 0x0e,                 // signed int 8
                "azim"   : 0x0028,               // signed int 16
                "prRes"  : (0xfffa << 16) >> 16, // signed int 16
                "flags"  : _getExpectedSatFlags(0x1f, 0x19)
            },
            {   // idx = 7
                // 00 1c 00 36 ec 00 00 00 11 12 00 00
                "gnssId" : 0x00,
                "svId"   : 0x1c,
                "cno"    : 0x00,
                "elev"   : 0x36,    // signed int 8
                "azim"   : 0x00ec,  // signed int 16
                "prRes"  : 0x0000,  // signed int 16
                "flags"  : _getExpectedSatFlags(0x11, 0x12)
            },
            {   // idx = 8
                // 00 1e 2c 3e 46 01 0a 00 1f 19 00 00
                "gnssId" : 0x00,
                "svId"   : 0x1e,
                "cno"    : 0x2c,
                "elev"   : 0x3e,    // signed int 8
                "azim"   : 0x0146,  // signed int 16
                "prRes"  : 0x000a,  // signed int 16
                "flags"  : _getExpectedSatFlags(0x1f, 0x19)
            },
            {   // idx = 9
                // 01 85 00 28 90 00 00 00 01 07 00 00
                "gnssId" : 0x01,
                "svId"   : 0x85,
                "cno"    : 0x00,
                "elev"   : 0x28,    // signed int 8
                "azim"   : 0x0090,  // signed int 16
                "prRes"  : 0x0000,  // signed int 16
                "flags"  : _getExpectedSatFlags(0x01, 0x07)
            },
            {   // idx = 10
                // 01 87 00 2d c6 00 00 00 01 07 00 00
                "gnssId" : 0x01,
                "svId"   : 0x87,
                "cno"    : 0x00,
                "elev"   : 0x2d,    // signed int 8
                "azim"   : 0x00c6,  // signed int 16
                "prRes"  : 0x0000,  // signed int 16
                "flags"  : _getExpectedSatFlags(0x01, 0x07)
            },
            {   // idx = 11
                // 01 8a 00 2c 9c 00 00 00 01 07 00 00
                "gnssId" : 0x01,
                "svId"   : 0x8a,
                "cno"    : 0x00,
                "elev"   : 0x2c,    // signed int 8
                "azim"   : 0x009c,  // signed int 16
                "prRes"  : 0x0000,  // signed int 16
                "flags"  : _getExpectedSatFlags(0x01, 0x07)
            },
            {   // idx = 12
                // 05 01 00 a5 00 00 00 00 01 00 00 00
                "gnssId" : 0x05,
                "svId"   : 0x01,
                "cno"    : 0x00,
                "elev"   : (0xa5 << 24) >> 24,  // signed int 8
                "azim"   : 0x0000,              // signed int 16
                "prRes"  : 0x0000,              // signed int 16
                "flags"  : _getExpectedSatFlags(0x01, 0x00)
            },
            {   // idx = 13
                // 05 04 00 a5 00 00 00 00 01 00 00 00
                "gnssId" : 0x05,
                "svId"   : 0x04,
                "cno"    : 0x00,
                "elev"   : (0xa5 << 24) >> 24,  // signed int 8
                "azim"   : 0x0000,              // signed int 16
                "prRes"  : 0x0000,              // signed int 16
                "flags"  : _getExpectedSatFlags(0x01, 0x00)
            },
            {   // idx = 14
                // 05 05 00 a5 00 00 00 00 01 00 00 00
                "gnssId" : 0x05,
                "svId"   : 0x05,
                "cno"    : 0x00,
                "elev"   : (0xa5 << 24) >> 24,  // signed int 8
                "azim"   : 0x0000,              // signed int 16
                "prRes"  : 0x0000,              // signed int 16
                "flags"  : _getExpectedSatFlags(0x01, 0x00)
            },
            {   // idx = 15
                // 06 01 00 0e b8 00 00 00 11 12 00 00
                "gnssId" : 0x06,
                "svId"   : 0x01,
                "cno"    : 0x00,
                "elev"   : 0x0e,    // signed int 8
                "azim"   : 0x00b8,  // signed int 16
                "prRes"  : 0x0000,  // signed int 16
                "flags"  : _getExpectedSatFlags(0x11, 0x012)
            },
            {   // idx = 16
                // 06 02 15 37 f4 00 00 00 14 12 00 00
                "gnssId" : 0x06,
                "svId"   : 0x02,
                "cno"    : 0x15,
                "elev"   : 0x37,    // signed int 8
                "azim"   : 0x00f4,  // signed int 16
                "prRes"  : 0x0000,  // signed int 16
                "flags"  : _getExpectedSatFlags(0x14, 0x012)
            },
            {   // idx = 17
                // 06 03 21 20 3e 01 c1 ff 1f 19 00 00
                "gnssId" : 0x06,
                "svId"   : 0x03,
                "cno"    : 0x21,
                "elev"   : 0x20,                 // signed int 8
                "azim"   : 0x013e,               // signed int 16
                "prRes"  : (0xffc1 << 16) >> 16, // signed int 16
                "flags"  : _getExpectedSatFlags(0x1f, 0x019)
            },
            {   // idx = 18
                // 06 0b 27 19 35 00 21 00 1f 19 00 00
                "gnssId" : 0x06,
                "svId"   : 0x0b,
                "cno"    : 0x27,
                "elev"   : 0x19,    // signed int 8
                "azim"   : 0x0035,  // signed int 16
                "prRes"  : 0x0021,  // signed int 16
                "flags"  : _getExpectedSatFlags(0x1f, 0x019)
            },
            {   // idx = 19
                // 06 0c 21 36 05 00 55 00 1f 19 00 00
                "gnssId" : 0x06,
                "svId"   : 0x0c,
                "cno"    : 0x21,
                "elev"   : 0x36,    // signed int 8
                "azim"   : 0x0005,  // signed int 16
                "prRes"  : 0x0055,  // signed int 16
                "flags"  : _getExpectedSatFlags(0x1f, 0x019)
            },
            {   // idx = 20
                // 06 0d 0b 1c 19 01 00 00 14 12 00 00
                "gnssId" : 0x06,
                "svId"   : 0x0d,
                "cno"    : 0x0b,
                "elev"   : 0x1c,    // signed int 8
                "azim"   : 0x0119,  // signed int 16
                "prRes"  : 0x0000,  // signed int 16
                "flags"  : _getExpectedSatFlags(0x14, 0x012)
            },
            {   // idx = 21
                // 06 15 1d 17 38 00 1b 00 1e 19 00 00
                "gnssId" : 0x06,
                "svId"   : 0x15,
                "cno"    : 0x1d,
                "elev"   : 0x17,    // signed int 8
                "azim"   : 0x0038,  // signed int 16
                "prRes"  : 0x001b,  // signed int 16
                "flags"  : _getExpectedSatFlags(0x1e, 0x019)
            },
            {   // idx = 22
                // 06 16 1a 16 75 00 00 00 16 12 00 00
                "gnssId" : 0x06,
                "svId"   : 0x16,
                "cno"    : 0x1a,
                "elev"   : 0x16,    // signed int 8
                "azim"   : 0x0075,  // signed int 16
                "prRes"  : 0x0000,  // signed int 16
                "flags"  : _getExpectedSatFlags(0x16, 0x012)
            }
        ]

        foreach (idx, sat in parsed.satInfo) {
            local ex = expected[idx];
            assertTrue("gnssId" in sat && typeof sat.gnssId == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "gnssId"));
            assertEqual(ex.gnssId, sat.gnssId, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo " + idx + " gnssId"));

            assertTrue("svId" in sat && typeof sat.svId == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "svId"));
            assertEqual(ex.svId, sat.svId, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo " + idx + " svId"));

            assertTrue("cno" in sat && typeof sat.cno == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "cno"));
            assertEqual(ex.cno, sat.cno, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo " + idx + " cno"));

            assertTrue("elev" in sat && typeof sat.elev == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "elev"));
            assertEqual(ex.elev, sat.elev, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo " + idx + " elev"));

            assertTrue("azim" in sat && typeof sat.azim == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "azim"));
            assertEqual(ex.azim,sat.azim, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo " + idx + " azim"));

            assertTrue("prRes" in sat && typeof sat.prRes == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "prRes"));
            assertEqual(ex.prRes, sat.prRes, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo " + idx + " prRes"));

            assertTrue("flags" in sat && typeof sat.flags == "table", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "satInfo " + idx + " flags"));

            local flags = sat.flags;
            local exFlags = ex.flags;
            assertEqual(flags.qualityInd, exFlags.qualityInd, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo " + idx + " flags qualityInd"));
            assertEqual(flags.svUsed, exFlags.svUsed, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo " + idx + " flags svUsed"));
            assertEqual(flags.health, exFlags.health, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo " + idx + " flags health"));
            assertEqual(flags.diffCorr, exFlags.diffCorr, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo " + idx + " flags diffCorr"));
            assertEqual(flags.smoothed, exFlags.smoothed, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo " + idx + " flags smoothed"));
            assertEqual(flags.orbitSource, exFlags.orbitSource, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo " + idx + " flags orbitSource"));
            assertEqual(flags.ephAvail, exFlags.ephAvail, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo " + idx + " flags ephAvail"));
            assertEqual(flags.almAvail, exFlags.almAvail, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo " + idx + " flags almAvail"));
            assertEqual(flags.anoAvail, exFlags.anoAvail, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo " + idx + " flags anoAvail"));
            assertEqual(flags.aopAvail, exFlags.aopAvail, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo " + idx + " flags aopAvail"));
            assertEqual(flags.sbasCorrUsed, exFlags.sbasCorrUsed, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo " + idx + " flags sbasCorrUsed"));
            assertEqual(flags.rtcmCorrUsed, exFlags.rtcmCorrUsed, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo " + idx + " flags rtcmCorrUsed"));
            assertEqual(flags.slasCorrUsed, exFlags.slasCorrUsed, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo " + idx + " flags slasCorrUsed"));
            assertEqual(flags.prCorrUsed, exFlags.prCorrUsed, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo " + idx + " flags prCorrUsed"));
            assertEqual(flags.crCorrUsed, exFlags.crCorrUsed, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo " + idx + " flags crCorrUsed"));
            assertEqual(flags.doCorrUsed, exFlags.doCorrUsed, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "satInfo " + idx + " flags doCorrUsed"));
        }

        return "Valid NAV-SAT message with satInfo parse test passed.";
    }

    function testNavSatInvalid() {
        local payload = _createPayload(UBX_INVALID_MSG.NAV_SAT);
        local parsed = UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.NAV_SAT](payload);
        local error = format(UbxMsgParser.ERROR_PARSING, "");

        assertTrue(crypto.equals(payload, parsed.payload), TEST_ERROR_MSG.PAYLOAD);
        assertTrue(parsed.error.find(error) != null, TEST_ERROR_MSG.ERROR_MISSING);

        return "Invalid NAV-SAT message returned expected error.";
    }

    function testAckAckValid() {
        // binary: 06 01
        // Tests all fields are present and are expected type & value
        local payload = _createPayload(UBX_VALID_MSG.ACK_ACK);
        local parsed = UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.ACK_ACK](payload);

        assertTrue(crypto.equals(payload, parsed.payload), TEST_ERROR_MSG.PAYLOAD);
        assertEqual(null, parsed.error, TEST_ERROR_MSG.ERROR_NOT_NULL);

        assertTrue("ackMsgClassId" in parsed && (typeof parsed.ackMsgClassId == "integer"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "ackMsgClassId"));
        assertEqual(0x0601, parsed.ackMsgClassId, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "ackMsgClassId"));

        return "Valid ACK-ACK message parse test passed.";
    }

    function testAckAckInvalid() {
        local payload = _createPayload(UBX_INVALID_MSG.ACK_ACK);
        local parsed = UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.ACK_ACK](payload);
        local error = format(UbxMsgParser.ERROR_PARSING, "");

        assertTrue(crypto.equals(payload, parsed.payload), TEST_ERROR_MSG.PAYLOAD);
        assertTrue(parsed.error.find(error) != null, TEST_ERROR_MSG.ERROR_MISSING);

        return "Invalid ACK-ACK message returned expected error.";
    }

    function testAckNakValid() {
        // binary: 06 01
        // Tests all fields are present and are expected type & value
        local payload = _createPayload(UBX_VALID_MSG.ACK_NAK);
        local parsed = UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.ACK_NAK](payload);

        assertTrue(crypto.equals(payload, parsed.payload), TEST_ERROR_MSG.PAYLOAD);
        assertEqual(null, parsed.error, TEST_ERROR_MSG.ERROR_NOT_NULL);

        assertTrue("nakMsgClassId" in parsed && (typeof parsed.nakMsgClassId == "integer"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "nakMsgClassId"));
        assertEqual(0x0601, parsed.nakMsgClassId, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "nakMsgClassId"));

        return "Valid ACK-NAK message parse test passed.";
    }

    function testAckNakInvalid() {
        local payload = _createPayload(UBX_INVALID_MSG.ACK_NAK);
        local parsed = UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.ACK_NAK](payload);
        local error = format(UbxMsgParser.ERROR_PARSING, "");

        assertTrue(crypto.equals(payload, parsed.payload), TEST_ERROR_MSG.PAYLOAD);
        assertTrue(parsed.error.find(error) != null, TEST_ERROR_MSG.ERROR_MISSING);

        return "Invalid ACK-NAK message returned expected error.";
    }

    function testMonVerValidWithExSw() {
        // binary: 32 2e 30 31 20 28 37 35 33 33 31 29 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 30 30 30 38 30 30 30 30 00 00 50 52 4f 54 56 45 52 20 31 35 2e 30 30 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 47 50 53 3b 53 42 41 53 3b 47 4c 4f 3b 42 44 53 3b 51 5a 53 53 00 00 00 00 00 00 00 00 00
        // Tests all fields are present and are expected type & value
        local payload = _createPayload(UBX_VALID_MSG.MON_VER);
        local parsed = UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.MON_VER](payload);

        assertTrue(crypto.equals(payload, parsed.payload), TEST_ERROR_MSG.PAYLOAD);
        assertEqual(null, parsed.error, TEST_ERROR_MSG.ERROR_NOT_NULL);

        assertTrue("swVersion" in parsed && (typeof parsed.swVersion == "string"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "swVersion"));
        assertEqual("2.01 (75331)", parsed.swVersion, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "swVersion"));
        assertTrue("hwVersion" in parsed && (typeof parsed.hwVersion == "string"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "hwVersion"));
        assertEqual("00080000", parsed.hwVersion, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "hwVersion"));

        local expectedExSwInfo = [
            "PROTVER 15.00",
            "GPS;SBAS;GLO;BDS;QZSS"
        ];
        local swInfo = parsed.exSwInfo;

        assertTrue("exSwInfo" in parsed && (typeof swInfo == "array"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "exSwInfo"));
        foreach(idx, infoStr in swInfo) {
            assertEqual(expectedExSwInfo[idx], infoStr, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "exSwInfo at index " + idx));
        }

        return "Valid MON-VER message with extended info parse test passed.";
    }

    function testMonVerValidWithOutExSw() {
        // binary: 32 2e 30 31 20 28 37 35 33 33 31 29 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 30 30 30 38 30 30 30 30 00 00
        // Tests all fields are present and are expected type & value
        local payload = _createPayload(UBX_VALID_MSG.MON_VER_NO_EX);
        local parsed = UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.MON_VER](payload);

        assertTrue(crypto.equals(payload, parsed.payload), TEST_ERROR_MSG.PAYLOAD);
        assertEqual(null, parsed.error, TEST_ERROR_MSG.ERROR_NOT_NULL);

        assertTrue("swVersion" in parsed && (typeof parsed.swVersion == "string"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "swVersion"));
        assertEqual("2.01 (75331)", parsed.swVersion, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "swVersion"));
        assertTrue("hwVersion" in parsed && (typeof parsed.hwVersion == "string"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "hwVersion"));
        assertEqual("00080000", parsed.hwVersion, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "hwVersion"));
        assertTrue(!("exSwInfo" in parsed), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "exSwInfo"));

        return "Valid MON-VER message without extended info parse test passed.";
    }

    function testMonVerInvalid() {
        local payload = _createPayload(UBX_INVALID_MSG.MON_VER);
        local parsed = UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.MON_VER](payload);
        local error = format(UbxMsgParser.ERROR_PARSING, "");

        assertTrue(crypto.equals(payload, parsed.payload), TEST_ERROR_MSG.PAYLOAD);
        assertTrue(parsed.error.find(error) != null, TEST_ERROR_MSG.ERROR_MISSING);

        return "Invalid MON-VER message returned expected error.";
    }

    function testMonHwValid() {
        // binary: 00 f4 01 00 00 00 00 00 00 00 01 00 ef f7 00 00 6c 00 00 00 00 01 00 84 ff eb 01 00 0a 0b 0c 0d 0e 0f 01 00 02 03 ff 10 ff 12 13 36 35 00 0f 5e
        // 00 00 00 00 80 f7 00 00 00 00 00 00
        // Tests all fields are present and are expected type & value
        local payload = _createPayload(UBX_VALID_MSG.MON_HW);
        local parsed = UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.MON_HW](payload);

        assertTrue(crypto.equals(payload, parsed.payload), TEST_ERROR_MSG.PAYLOAD);
        assertEqual(null, parsed.error, TEST_ERROR_MSG.ERROR_NOT_NULL);

        assertTrue("pinSel" in parsed && (typeof parsed.pinSel == "blob"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "pinSel"));
        assertTrue(crypto.equals("\x00\xf4\x01\x00", parsed.pinSel), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "pinSel"));

        assertTrue("pinBank" in parsed && (typeof parsed.pinBank == "blob"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "pinBank"));
        assertTrue(crypto.equals("\x00\x00\x00\x00", parsed.pinBank), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "pinBank"));

        assertTrue("pinDir" in parsed && (typeof parsed.pinDir == "blob"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "pinDir"));
        assertTrue(crypto.equals("\x00\x00\x01\x00", parsed.pinDir), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "pinDir"));

        assertTrue("pinVal" in parsed && (typeof parsed.pinVal == "blob"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "pinVal"));
        assertTrue(crypto.equals("\xef\xf7\x00\x00", parsed.pinVal), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "pinVal"));

        assertTrue("noisePerMS" in parsed && (typeof parsed.noisePerMS == "integer"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "noisePerMS"));
        assertEqual(0x006c, parsed.noisePerMS, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "noisePerMS"));

        assertTrue("agcCnt" in parsed && (typeof parsed.agcCnt == "integer"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "agcCnt"));
        assertEqual(0x0000, parsed.agcCnt, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "agcCnt"));

        assertTrue("aStatus" in parsed && (typeof parsed.aStatus == "integer"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "aStatus"));
        assertEqual(0x00, parsed.aStatus, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "aStatus"));

        assertTrue("aPower" in parsed && (typeof parsed.aPower == "integer"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "aPower"));
        assertEqual(0x01, parsed.aPower, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "aPower"));

        assertTrue("flags" in parsed && (typeof parsed.flags == "table"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "flags"));

        local expectedFlags = {
            "rtcCalib"      : 0,
            "safeBoot"      : 0,
            "jammingState"  : 0,
            "xtalAbsent"    : 0
        }
        local flags = parsed.flags;

        assertTrue("rtcCalib" in flags && (typeof flags.rtcCalib == "integer"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "rtcCalib"));
        assertEqual(0, flags.rtcCalib, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "rtcCalib flag"));

        assertTrue("safeBoot" in flags && (typeof flags.safeBoot == "integer"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "safeBoot"));
        assertEqual(0, flags.safeBoot, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "safeBoot flag"));

        assertTrue("jammingState" in flags && (typeof flags.jammingState == "integer"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "jammingState"));
        assertEqual(0, flags.jammingState, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "jammingState flag"));

        assertTrue("xtalAbsent" in flags && (typeof flags.safeBoot == "integer"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "xtalAbsent"));
        assertEqual(0, flags.safeBoot, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "xtalAbsent flag"));

        assertTrue("usedMask" in parsed && (typeof parsed.usedMask == "blob"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "usedMask"));
        assertTrue(crypto.equals("\xff\xeb\x01\x00", parsed.usedMask), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "usedMask"));

        assertTrue("vp" in parsed && (typeof parsed.vp == "blob"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "vp"));
        assertTrue(crypto.equals("\x0a\x0b\x0c\x0d\x0e\x0f\x01\x00\x02\x03\xff\x10\xff\x12\x13\x36\x35", parsed.vp), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "vp"));

        assertTrue("jamInd" in parsed && (typeof parsed.jamInd == "integer"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "jamInd"));
        assertEqual(0x00, parsed.jamInd, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "jamInd"));

        assertTrue("pinIrq" in parsed && (typeof parsed.pinIrq == "blob"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "pinIrq"));
        assertTrue(crypto.equals("\x00\x00\x00\x00", parsed.pinIrq), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "pinIrq"));

        assertTrue("pullH" in parsed && (typeof parsed.pullH == "blob"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "pullH"));
        assertTrue(crypto.equals("\x80\xf7\x00\x00", parsed.pullH), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "pullH"));

        assertTrue("pullL" in parsed && (typeof parsed.pullL == "blob"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "pullL"));
        assertTrue(crypto.equals("\x00\x00\x00\x00", parsed.pullL), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "pullL"));

        return "Valid MON-HW message parse test passed.";
    }

    function testMonHwInvalid() {
        local payload = _createPayload(UBX_INVALID_MSG.MON_HW);
        local parsed = UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.MON_HW](payload);
        local error = format(UbxMsgParser.ERROR_PARSING, "");

        assertTrue(crypto.equals(payload, parsed.payload), TEST_ERROR_MSG.PAYLOAD);
        assertTrue(parsed.error.find(error) != null, TEST_ERROR_MSG.ERROR_MISSING);

        return "Invalid MON-HW message returned expected error.";
    }

    function tearDown() {
        return "Test finished";
    }

}


// Sample payloads from M8N
// ----------------------------------------------------------------------
// Msg Class ID: 0x0A09
// Msg len: 60
// binary: 00 f4 01 00 00 00 00 00 00 00 01 00 ef f7 00 00 6c 00 00 00 00 01 00 84 ff eb 01 00 0a 0b 0c 0d 0e 0f 01 00 02 03 ff 10 ff 12 13 36 35 00 0f 5e 00 00 00 00 80 f7 00 00 00 00 00 00

// Msg Class ID: 0x0107
// Msg len: 92
// binary: e8 03 00 00 dd 07 09 01 00 00 01 f0 ff ff ff ff 00 00 00 00 00 00 04 00 00 00 00 00 00 00 00 00 00 00 00 00 98 bd ff ff ff ff ff ff 00 76 84 df 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 20 4e 00 00 80 a8 12 01 0f 27 00 00 86 4c 22 00 00 00 00 00 ff 00 00 00
// binary: d0 09 b7 19 e3 07 01 18 17 32 08 f7 f7 03 00 00 a6 6c 02 00 03 01 0a 0b 44 aa 38 b7 fb 1a 4a 16 4b 5a 00 00 8a cf 00 00 2a 18 00 00 d7 10 00 00 f9 ff ff ff f9 ff ff ff fd ff ff ff 0a 00 00 00 00 00 00 00 61 01 00 00 14 6e 01 01 9a 00 00 e0 86 4c 22 00 00 00 02 00 00 00 00 80

// Msg Class ID: 0x0135
// Msg len: 8
// binary: e8 03 00 00 01 00 00 00
// Msg Class ID: 0x0135
// Msg len: 284
// binary: 30 f4 b7 19 01 17 00 00 00 05 0c 15 1c 01 63 00 1c 19 00 00 00 07 30 3e 32 00 ef ff 1f 19 00 00 00 08 25 23 3f 00 fd ff 1f 09 00 00 00 0b 00 10 75 00 00 00 11 09 00 00 00 0d 1f 0c 3d 01 6a ff 1e 09 00 00 00 17 19 0d 93 00 75 00 1c 19 00 00 00 1b 22 0e 28 00 fa ff 1f 19 00 00 00 1c 00 36 ec 00 00 00 11 12 00 00 00 1e 2c 3e 46 01 0a 00 1f 19 00 00 01 85 00 28 90 00 00 00 01 07 00 00 01 87 00 2d c6 00 00 00 01 07 00 00 01 8a 00 2c 9c 00 00 00 01 07 00 00 05 01 00 a5 00 00 00 00 01 00 00 00 05 04 00 a5 00 00 00 00 01 00 00 00 05 05 00 a5 00 00 00 00 01 00 00 00 06 01 00 0e b8 00 00 00 11 12 00 00 06 02 15 37 f4 00 00 00 14 12 00 00 06 03 21 20 3e 01 c1 ff 1f 19 00 00 06 0b 27 19 35 00 21 00 1f 19 00 00 06 0c 21 36 05 00 55 00 1f 19 00 00 06 0d 0b 1c 19 01 00 00 14 12 00 00 06 15 1d 17 38 00 1b 00 1e 19 00 00 06 16 1a 16 75 00 00 00 16 12 00 00

// Msg Class ID: 0x0A04
// Msg len: 100
// binary: 32 2e 30 31 20 28 37 35 33 33 31 29 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 30 30 30 38 30 30 30 30 00 00 50 52 4f 54 56 45 52 20 31 35 2e 30 30 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 47 50 53 3b 53 42 41 53 3b 47 4c 4f 3b 42 44 53 3b 51 5a 53 53 00 00 00 00 00 00 00 00 00

// Msg Class ID: 0x1360
// Msg len: 8
// binary: 01 00 00 06 02 00 18 00
// binary: 01 00 00 00 04 00 00 00
// binary: 01 00 00 00 06 00 00 00
// binary: 01 00 00 00 05 00 00 00
// binary: 01 00 00 06 03 00 62 04
// binary: 01 00 00 40 30 00 00 00
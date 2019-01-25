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

// Sample payloads from M8N
// Msg Class ID: 0x0A09
// Msg len: 60
// binary: 00 f4 01 00 00 00 00 00 00 00 01 00 ef f7 00 00 6c 00 00 00 00 01 00 84 ff eb 01 00 0a 0b 0c 0d 0e 0f 01 00 02 03 ff 10 ff 12 13 36 35 00 0f 5e 00 00 00 00 80 f7 00 00 00 00 00 00

// Msg Class ID: 0x0107
// Msg len: 92
// binary: e8 03 00 00 dd 07 09 01 00 00 01 f0 ff ff ff ff 00 00 00 00 00 00 04 00 00 00 00 00 00 00 00 00 00 00 00 00 98 bd ff ff ff ff ff ff 00 76 84 df 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 20 4e 00 00 80 a8 12 01 0f 27 00 00 86 4c 22 00 00 00 00 00 ff 00 00 00
// Msg Class ID: 0x0107
// Msg len: 92
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

@include __PATH__+"/../Parser/UbxMsgParser.lib.nut"

enum UBX_VALID_MSG {
    NAV_PVT = "\xd0\x09\xb7\x19\xe3\x07\x01\x18\x17\x32\x08\xf7\xf7\x03\x00\x00\xa6\x6c\x02\x00\x03\x01\x0a\x0b\x44\xaa\x38\xb7\xfb\x1a\x4a\x16\x4b\x5a\x00\x00\x8a\xcf\x00\x00\x2a\x18\x00\x00\xd7\x10\x00\x00\xf9\xff\xff\xff\xf9\xff\xff\xff\xfd\xff\xff\xff\x0a\x00\x00\x00\x00\x00\x00\x00\x61\x01\x00\x00\x14\x6e\x01\x01\x9a\x00\x00\xe0\x86\x4c\x22\x00\x00\x00\x02\x00\x00\x00\x00\x80",
    NAV_SAT_LONG = "\x30\xf4\xb7\x19\x01\x17\x00\x00\x00\x05\x0c\x15\x1c\x01\x63\x00\x1c\x19\x00\x00\x00\x07\x30\x3e\x32\x00\xef\xff\x1f\x19\x00\x00\x00\x08\x25\x23\x3f\x00\xfd\xff\x1f\x09\x00\x00\x00\x0b\x00\x10\x75\x00\x00\x00\x11\x09\x00\x00\x00\x0d\x1f\x0c\x3d\x01\x6a\xff\x1e\x09\x00\x00\x00\x17\x19\x0d\x93\x00\x75\x00\x1c\x19\x00\x00\x00\x1b\x22\x0e\x28\x00\xfa\xff\x1f\x19\x00\x00\x00\x1c\x00\x36\xec\x00\x00\x00\x11\x12\x00\x00\x00\x1e\x2c\x3e\x46\x01\x0a\x00\x1f\x19\x00\x00\x01\x85\x00\x28\x90\x00\x00\x00\x01\x07\x00\x00\x01\x87\x00\x2d\xc6\x00\x00\x00\x01\x07\x00\x00\x01\x8a\x00\x2c\x9c\x00\x00\x00\x01\x07\x00\x00\x05\x01\x00\xa5\x00\x00\x00\x00\x01\x00\x00\x00\x05\x04\x00\xa5\x00\x00\x00\x00\x01\x00\x00\x00\x05\x05\x00\xa5\x00\x00\x00\x00\x01\x00\x00\x00\x06\x01\x00\x0e\xb8\x00\x00\x00\x11\x12\x00\x00\x06\x02\x15\x37\xf4\x00\x00\x00\x14\x12\x00\x00\x06\x03\x21\x20\x3e\x01\xc1\xff\x1f\x19\x00\x00\x06\x0b\x27\x19\x35\x00\x21\x00\x1f\x19\x00\x00\x06\x0c\x21\x36\x05\x00\x55\x00\x1f\x19\x00\x00\x06\x0d\x0b\x1c\x19\x01\x00\x00\x14\x12\x00\x00\x06\x15\x1d\x17\x38\x00\x1b\x00\x1e\x19\x00\x00\x06\x16\x1a\x16\x75\x00\x00\x00\x16\x12\x00\x00"
    NAV_SAT_SHORT = "\xe8\x03\x00\x00\x01\x00\x00\x00",
    ACK_ACK = "\x06\x01",
    ACK_NAK = "\x06\x01",
    MON_HW  = "\x00\xf4\x01\x00\x00\x00\x00\x00\x00\x00\x01\x00\xef\xf7\x00\x00\x6c\x00\x00\x00\x00\x01\x00\x84\xff\xeb\x01\x00\x0a\x0b\x0c\x0d\x0e\x0f\x01\x00\x02\x03\xff\x10\xff\x12\x13\x36\x35\x00\x0f\x5e\x00\x00\x00\x00\x80\xf7\x00\x00\x00\x00\x00\x00",
    MON_VER = "\x32\x2e\x30\x31\x20\x28\x37\x35\x33\x33\x31\x29\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x30\x30\x30\x38\x30\x30\x30\x30\x00\x00\x50\x52\x4f\x54\x56\x45\x52\x20\x31\x35\x2e\x30\x30\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x47\x50\x53\x3b\x53\x42\x41\x53\x3b\x47\x4c\x4f\x3b\x42\x44\x53\x3b\x51\x5a\x53\x53\x00\x00\x00\x00\x00\x00\x00\x00\x00",
    MGA_ACK = ""
}

enum UBX_INVALID_MSG {
    NAV_PVT = "\xd0\x09\xb7\x19\xe3\x07",
    NAV_SAT = "\x06\x01",
    ACK_ACK = "a",
    ACK_NAK = "m",
    MON_HW  = "\x06\x01",
    MON_VER = "\x06\x01",
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

    function setUp() {
        return "No setUp needed for this test";
    }

    function testNavPvtValid() {
        // Tests all fields are present and are expected type
        local payload = _createPayload(UBX_VALID_MSG.NAV_PVT);
        local parsed = UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.NAV_PVT](payload);

        assertTrue(crypto.equals(payload, parsed.payload), TEST_ERROR_MSG.PAYLOAD);
        assertEqual(null, parsed.error, TEST_ERROR_MSG.ERROR_NOT_NULL);

        assertTrue("iTOW" in parsed && (typeof parsed.iTOW == "blob"), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "iTOW"));
        assertTrue(crypto.equals("\xd0\x09\xb7\x19", parsed.iTOW), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "iTOW"));

        assertTrue("year" in parsed && typeof parsed.year == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "year"));
        assertTrue(2019 == parsed.year, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "year"));

        assertTrue("month" in parsed && typeof parsed.month == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "month"));
        assertTrue(1 == parsed.month, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "month"));

        assertTrue("day" in parsed && typeof parsed.day == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "day"));
        assertTrue(0x18 == parsed.day, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "day"));

        assertTrue("hour" in parsed && typeof parsed.hour == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "hour"));
        assertTrue(0x17 == parsed.hour, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "hour"));

        assertTrue("min" in parsed && typeof parsed.min == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "min"));
        assertTrue(0x32 == parsed.min, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "min"));

        assertTrue("sec" in parsed && typeof parsed.sec == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "sec"));
        assertTrue(0x08 == parsed.sec, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "sec"));

        assertTrue("valid" in parsed && typeof parsed.valid == "table", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "valid"));
        local valid = parsed.valid; // 0xf7
        assertTrue("validDate" in valid && valid.validDate, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "validDate"));
        assertTrue("validTime" in valid && valid.validTime, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "validTime"));
        assertTrue("fullyResolved" in valid && valid.fullyResolved, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "fullyResolved"));
        assertTrue("validMag" in valid && !valid.validMag, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "validMag"));

        assertTrue("tAcc" in parsed && typeof parsed.tAcc == "blob", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "tAcc"));
        assertTrue(crypto.equals("\xf7\x03\x00\x00", parsed.tAcc), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "tAcc"));

        assertTrue("nano" in parsed && typeof parsed.nano == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "nano"));
        assertTrue(0x00026ca6 == parsed.nano, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "nano"));

        assertTrue("fixType" in parsed && typeof parsed.fixType == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "fixType"));
        assertTrue(0x03 == parsed.fixType, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "fixType"));

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
        assertTrue(0x0b == parsed.numSV, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "numSV"));

        assertTrue("lon" in parsed && typeof parsed.lon == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "lon"));
        assertTrue(0xb738aa44 == parsed.lon, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "lon"));

        assertTrue("lat" in parsed && typeof parsed.lat == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "lat"));
        assertTrue(0x164a1afb == parsed.lat, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "lat"));

        assertTrue("height" in parsed && typeof parsed.height == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "height"));
        assertTrue(0x00005a4b == parsed.height, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "height"));

        assertTrue("hMSL" in parsed && typeof parsed.hMSL == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "hMSL"));
        assertTrue(0x0000cf8a == parsed.hMSL, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "hMSL"));

        assertTrue("hAcc" in parsed && typeof parsed.hAcc == "blob", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "hAcc"));
        assertTrue(crypto.equals("\x2a\x18\x00\x00", parsed.hAcc), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "hAcc"));

        assertTrue("vAcc" in parsed && typeof parsed.vAcc == "blob", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "vAcc"));
        assertTrue(crypto.equals("\xd7\x10\x00\x00", parsed.vAcc), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "vAcc"));

        assertTrue("velN" in parsed && typeof parsed.velN == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "velN"));
        assertTrue(0xfffffff9 == parsed.velN, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "velN"));

        assertTrue("velE" in parsed && typeof parsed.velE == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "velE"));
        assertTrue(0xfffffff9 == parsed.velE, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "velE"));

        assertTrue("velD" in parsed && typeof parsed.velD == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "velD"));
        assertTrue(0xfffffffd == parsed.velD, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "velD"));

        assertTrue("gSpeed" in parsed && typeof parsed.gSpeed == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "gSpeed"));
        assertTrue(0x0000000a == parsed.gSpeed, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "gSpeed"));

        assertTrue("headMot" in parsed && typeof parsed.headMot == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "headMot"));
        assertTrue(0x00000000 == parsed.headMot, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "headMot"));

        assertTrue("sAcc" in parsed && typeof parsed.sAcc == "blob", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "sAcc"));
        assertTrue(crypto.equals("\x61\x01\x00\x00", parsed.sAcc), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "sAcc"));

        assertTrue("headAcc" in parsed && typeof parsed.headAcc == "blob", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "headAcc"));
        assertTrue(crypto.equals("\x14\x6e\x01\x01", parsed.headAcc), format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "headAcc"));

        assertTrue("pDOP" in parsed && typeof parsed.pDOP == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "pDOP"));
        assertTrue(0x009a == parsed.pDOP, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "pDOP"));

        assertTrue("headVeh" in parsed && typeof parsed.headVeh == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "headVeh"));
        assertTrue(0x00020000 == parsed.headVeh, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "headVeh"));

        assertTrue("magDec" in parsed && typeof parsed.magDec == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "magDec"));
        assertTrue(0x0000 == parsed.magDec, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "magDec"));

        assertTrue("magAcc" in parsed && typeof parsed.magAcc == "integer", format(TEST_ERROR_MSG.UNEXPECTED_FIELD_TYPE, "magAcc"));
        assertTrue(0x8000 == parsed.magAcc, format(TEST_ERROR_MSG.UNEXPECTED_FIELD_VAL, "magAcc"));
    }

    function testNavPvtInvalid() {
        local payload = _createPayload(UBX_INVALID_MSG.NAV_PVT);
        local parsed = UbxMsgParser[UBX_MSG_PARSER_CLASS_MSG_ID.NAV_PVT](payload);
        local error = format(UbxMsgParser.ERROR_PARSING, "");

        assertTrue(crypto.equals(payload, parsed.payload), TEST_ERROR_MSG.PAYLOAD);
        assertTrue(parsed.error.find(error) != null, TEST_ERROR_MSG.ERROR_MISSING);
    }

    // function testNavSatShortValid() {

    // }

    // function testNavSatLongValid() {

    // }

    // function testNavSatInvalid() {

    // }

    // function testAckAckValid() {

    // }

    // function testAckAckInvalid() {

    // }

    // function testAckNakValid() {

    // }

    // function testAckNakInvalid() {

    // }

    // function testMonVerValid() {

    // }

    // function testMonVerInvalid() {

    // }

    // function testMonHwValid() {

    // }

    // function testMonHwInvalid() {

    // }

    // function testMgaAckValid() {

    // }

    // function testMgaAckInvalid() {

    // }

    function tearDown() {
        return "Test finished";
    }

}
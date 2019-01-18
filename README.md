# UBloxM8N #

Electric Imp offers two libraries to support the UBLOX M8N GPS module: a device-side driver class, and a parser. The libraries are based on the commands as defined by [Reciever Description Including Protocol Specification document](https://www.u-blox.com/sites/default/files/products/documents/u-blox8-M8_ReceiverDescrProtSpec_%28UBX-13003221%29_Public.pdf).

## UBloxM8N ##

UART driver for u-blox M8N GPS module.

**To add this library to your project, add** `#require "UBloxM8N.device.lib.nut:1.0.0"` **to the top of your device code.**

### Class Usage ###

#### onMessage Callback ####

When a valid message is received from the M8N it will be passed to an onMessage callback if there is one. For any message only **one** callback will be triggered. If a message specific callback is available it will be used. If no message specific callback is available, the more general type specific *onNmeaMsg* or *onUbxMsg* will be used. If there are no message specific and no type specific callbacks registered, then the *defaultOnMsg* will be used.

Callback Function Details:

| Callback Name | Register Callback Type | Parameters | Parameter Description(s) |
| --- | --- | --- | --- |
| *defaultOnMsg* | UBLOX_M8N_CONST.DEFAULT_ON_MSG | 1 required, 1 optional | first parameter (req): blob/string *payload/NMEA Sentence*, second parameter (opt): integer *class-id* |
| *onUbxMsg* | UBLOX_M8N_CONST.ON_UBX_MSG | 2 required | first parameter: blob *payload*, second parameter: integer *class-id* |
| *onNmeaMsg* | UBLOX_M8N_CONST.ON_NMEA_MSG | 1 required | first parameter: string *NMEA Sentence* |
| *ubx message specific callback* | Integer: Message Class Id | 1 required  | first parameter: blob *payload* |

#### Constructor: GPSUARTDriver(*uart[, bootTimeoutSec][, baudRateAtBoot]*) ####

Initializes u-blox M8N driver object. The constructor will initialize the specified hardware.uart object using the either the specified baud rate or a default baud rate of 9600 (the default baud rate specified in the u-blox data sheet).

##### Parameters #####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *uart* | string | Yes | An imp UART bus to which the GPS module is connected. |
| *bootTimeoutSec* | integer/float | No | The time in seconds to wait after boot before the GPS is be ready for commands. Default is 1 sec. |
| *baudRateAtBoot* | integer | No | The default baud rate that the GPS boot's up in after cold boot. This defaults to 9600 (the default specified in the u-blox data sheet). |

### Class Methods ###

#### configure(*options*) ####

Use this method to configure a new uart baud rate, define the message type(s) the M8N will accept, define the message type(s) the M8N will send, and to set default message callbacks for incoming messages from the M8N. **Note:** This method will re-configure the uart bus.

##### Parameters #####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *options* | table | Yes | A table of settings used to configure the u-blox module *(see below)* |

The *options* table may contain any of the following keys:

| Key | Type | Default | Description |
| --- | --- | --- |--- |
| *baudRate* | integer | The currently configured baud rate | The baud rate used to configure the UART |
| *outputMode* | integer | UBLOX_M8N_MSG_MODE.BOTH  | Use the enum UBLOX_M8N_MSG_MODE to select the output message format type(s) *(see below)* |
| *inputMode* | integer | UBLOX_M8N_MSG_MODE.BOTH | Use the enum UBLOX_M8N_MSG_MODE to select the input message format type(s) *(see below)* |
| *onNmeaMsg* | function | `null` | A callback function that is triggered when an NMEA sentence is received. *(see onMessage Callback above)* |
| *onUbxMsg* | function | `null` | A callback function that is triggered when an UBX message is received, if no message specific callback is defined. *(see onMessage Callback above)* |
| *defaultOnMsg* | function | `null` | A callback function that is triggered when any fully formed NMEA sentence or UBX message is recieved from the M8N, if no other callback is defined for that message. *(see onMessage Callback above)* |

Input/Output Mode Selector Options:

| Name | Value |
| --- | --- |
| *UBLOX_M8N_MSG_MODE.UBX_ONLY* | 0x0001 |
| *UBLOX_M8N_MSG_MODE.NMEA_ONLY* | 0x0002 |
| *UBLOX_M8N_MSG_MODE.BOTH* | 0x0003 |

##### Return Value #####

None.

#### toggleUbxMsg(*classId, rate[, onMessage]*) ####

Enables/Disables the UBX message at the specified rate. When messages are received they will be passed to the onMessage callback. If no onMessage callback is specified messages will be passed to either onUbxMsg or defaultOnMsg callback instead.

##### Parameters #####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *classId* | integer | Yes | The 2 byte message class and Id. |
| *rate* | integer | Yes | How often, in seconds, new messages should be sent. |
| *onMessage* | function | No | A callback function for incoming messages with this class-Id. If no callback is specified one of the more general onMessage callbacks will be used. *(see onMessage Callback above)* |

##### Return Value #####

None.

#### registerOnMessageCallback(*type, onMessage*) ####

Registers a message onMessage callback for incoming messages from the M8N.

##### Parameters #####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *type* | string/integer | Yes | Either the UBX 2 byte message class and Id, or one of the following onMessage callback types: UBLOX_M8N_CONST.DEFAULT_ON_MSG, UBLOX_M8N_CONST.ON_NMEA_MSG, UBLOX_M8N_CONST.ON_UBX_MSG |
| *onMessage* | function | Yes | A callback for incoming messages of this type. *(see onMessage Callback above)* |

##### Return Value #####

None.

#### writeUBX(*classid, payload*) ####

Writes a UBX protocol packet to the M8N. Note if your command expects a response be sure you have a callback registered.

##### Parameters #####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *classid* | integer | Yes | The 2 byte message class and ID. |
| *payload* | blob/string | Yes | The message payload. |

##### Return Value #####

None.

#### function writeNMEA(*sentence*) ####

Writes an NMEA protocol packet to the M8N.

##### Parameters #####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *sentence* | string | Yes | An NMEA formatted sentence with comma separated fields. If needed, this method will add the start character, ending characters, and the check sum to the sentence before writing. |

##### Return Value #####

None.

#### function writeMessage(*message*) ####

Writes a message to the M8N. Message is written to uart, no headers, check sum etc are added.

##### Parameters #####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *message* | blob/string | Yes | Message to write to M8N uart. |

##### Return Value #####

None.

#### function calcUbxChecksum(*packet*) ####

Calculates the check sum for a UBX packet. Packet must consist of only the following: message class(1 byte), message id (1 byte), payload length (2 bytes), and payload.

##### Parameters #####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *packet* | blob | Yes | Packet to calculate check sum on. |

##### Return Value #####

String, 2 byte check sum.

#### function calcNMEACheckSum(*sentence*) ####

Calculates the check sum for an NMEA sentence. This method will ignore starting and ending characters if they are in the sentence that is passed in.

##### Parameters #####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *sentence* | string | Yes | Sentence to calculate check sum on. |

##### Return Value #####

Integer, one byte check sum.

## UbxMsgParser ##

Parser for UBX binary messages. For information about UBX message  see [Reciever Description Including Protocol Specification document](https://www.u-blox.com/sites/default/files/products/documents/u-blox8-M8_ReceiverDescrProtSpec_%28UBX-13003221%29_Public.pdf).
This parser is a table, so it can be easily expanded. A small number of messages have been selected as a base. No initialization is needed. All slots in this table are the UBX the 2 byte message class and ID, and values are a function that takes the UBX message payload and returns the parsed payload. Parsed payloads are all tables, with the exception of ACK-ACK and ACK-NAK, which return the 2 byte message class and ID for the message being acknowleged. **Note:** Squirrel only supports signed 32 bit integers. If the paylaod conatins a 32 bit unsigned integer the parsed table will contain a 4 byte blob with the payload values. These values are in the same order as received by the M8N (little endian).

**To add this library to your project, add** `#require "UbxMsgParser.lib.nut:1.0.0"` **to the top of your code.**

### Class Methods ###

#### 0x0107 (*payload*) ####

Parses `0x0107` (NAV_PVT) UBX message payload.

##### Parameters #####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *payload* | blob | Yes | 100 byte NAV_PVT message payload. |

##### Return Value #####

A table.

| Key | Type | Description |
| --- | --- | --- |
| *iTOW* | blob | 4 byte unsigened integer, GPS time of week of the navigation epoch in ms. |
| *year* | integer | Year (UTC). |
| *month* | integer | Month, range 1..12 (UTC). |
| *day* | integer | Day of month, range 1..31 (UTC). |
| *hour* | integer | Hour of day, range 0..23 (UTC). |
| *min* | integer | Minute of hour, range 0..59 (UTC). |
| *sec* | integer | Seconds of minute, range 0..60 (UTC). |
| *valid* | table | Validity flags *(see Validity Flags below)*. |
| *tAcc* | integer | Time accuracy estimate in ns (UTC). |
| *nano* | integer | Fraction of second, range -1e9 .. 1e9 in ns (UTC). |
| *fixType* | integer | GNSSfix Type: 0 = no fix, 1 = dead reckoning only, 2 = 2D-fix, 3 = 3D-fix, 4 = GNSS + dead reckoning combined, 5 = time only fix |
| *fixStatusFlags* | table | Fix status flags *(see Fix Status Flags below)*. |
| *numSV* | integer | Number of satellites used in Nav Solution. |
| *lon* | integer | Longitude in deg. |
| *lat* | integer | Latitude in deg. |
| *height* | integer | Height above ellipsoid in mm. |
| *hMSL* | integer | Height above mean sea level mm. |
| *hAcc* | blob | 4 byte unsigened integer, Horizontal accuracy estimate in mm. |
| *vAcc* | blob | 4 byte unsigened integer, Vertical accuracy estimate in mm. |
| *velN* | integer | NED north velocity in mm/s. |
| *velE* | integer | NED east velocity in mm/s. |
| *velD* | integer | NED down velocity in mm/s. |
| *gSpeed* | integer | Ground Speed (2-D) in mm/s. |
| *headMot* | integer | Heading of motion (2-D) in deg. |
| *sAcc* | blob | 4 byte unsigened integer, Speed accuracy estimate in mm/s. |
| *headAcc* | blob | 4 byte unsigened integer, Heading accuracy estimate (both motion and vehicle) in mm/s. |
| *pDOP* | integer | Position DOP. |
| *headVeh* | integer | Heading of vehicle (2-D) in deg. |
| *magDec* | integer | Magnetic declination in deg. |
| *magAcc* | integer | Magnetic declination accuracy in deg. |

Validity Flags

| Key | Type | Description |
| --- | --- | --- |
| *validDate* | bool | valid UTC Date. |
| *validTime* | bool | valid UTC Time of Day. |
| *fullyResolved* | bool | UTC Time of Day has been fully resolved (no seconds uncertainty). |
| *validMag* | bool | valid Magnetic declination. |

Fix Status Flags

| Key | Type | Description |
| --- | --- | --- |
| *gnssFixOK* | integer | 1 = valid fix (i.e within DOP & accuracy masks). |
| *diffSoln* | integer | 1 = differential corrections were applied. |
| *psmState* | integer | Power Save Mode state: 0 = PSM is not active, 1 = Enabled (an intermediate state before Acquisition state), 2 = Acquisition, 3 = Tracking, 4 = Power Optimized Tracking, 5 = Inactive. |
| *headVehValid* | integer | 1 = heading of vehicle is valid. |
| *carrSoln* | integer | Carrier phase range solution status (not supported in protocol versions less than 20): 0: no carrier phase range solution, 1 = float solution (no fixed integer carrier phase measurements have been used to calculate the solution), 2 = fixed solution (one or more fixed integer carrier phase range measurements have been used to calculate the solution). |
| *confirmedAvai* | integer | 1 = information about UTC Date and Time of Day validity confirmation is available. (Not supported in all versions) |
| *confirmedDate* | integer | 1 = UTC Date validity could be confirmed. |
| *confirmedTime* | integer | 1 = UTC Time of Day could be confirmed. |

#### 0x0135 (*payload*) ####

Parses `0x0135` (NAV_SAT) UBX message payload.

##### Parameters #####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *payload* | blob | Yes | 8 + 12*n bytes NAV_SAT message payload. |

##### Return Value #####

A table.

| Key | Type | Description |
| --- | --- | --- |
| *iTOW* | blob | 4 byte unsigened integer, GPS time of week of the navigation epoch in ms. |
| *version* | integer | Message version (1 for this version). |
| *numSvs* | integer | Number of satellites. |
| *satInfo* | array | Array of satellite info tables *(see below)*. |

Satellite Info Tables

| Key | Type | Description |
| --- | --- | --- |
| *gnssId* | integer | GNSS identifier. |
| *svId* | integer | Satellite identifier. |
| *cno* | integer | Carrier to noise ratio (signal strength) in dBHz. |
| *elev* | integer | Elevation (range: +/-90), unknown if out of range, in deg. |
| *azim* | integer | Azimuth (range 0-360), unknown if elevation is out of range, in deg. |
| *prRes* | integer | Pseudorange residual in m. |
| *flags* | table | Table of flags *(see below)*. |

Satellite Info Flags

| Key | Type | Description |
| --- | --- | --- |
| *qualityInd* | integer | Signal quality indicator: 0 = no signal, 1 = searching signal, 2 = signal acquired, 3 = signal detected but unusable, 4 = code locked and time synchronized, 5, 6, 7 = code and carrier locked and time synchronized. |
| *svUsed* | integer | 1 = Signal in the subset specified in Signal Identifiers is currently being used for navigation. |
| *health* | integer | Signal health flag: 0 = unknown, 1 = healthy, 2 = unhealthy. |
| *diffCorr* | integer | 1 = differential correction data is available for this SV. |
| *smoothed* | integer | 1 = carrier smoothed pseudorange used. |
| *orbitSource* | integer | Orbit source: 0 = no orbit information is available for this SV, 1 = ephemeris is used, 2 = almanac is used, 3: AssistNow Offline orbit is used, 4 = AssistNow Autonomous orbit is used, 5, 6, 7: other orbit information is used. |
| *ephAvail* | integer | 1 = ephemeris is available for this SV. |
| *almAvail* | integer | 1 = almanac is available for this SV. |
| *anoAvail* | integer | 1 = AssistNow Offline data is available for this SV. |
| *aopAvail* | integer | 1 = AssistNow Autonomous data is available for this SV. |
| *sbasCorrUsed* | integer | 1 = SBAS corrections have been used for a signal. |
| *rtcmCorrUsed* | integer | 1 = RTCM corrections have been used. |
| *slasCorrUsed* | integer | 1 = QZSS SLAS corrections have been used. |
| *prCorrUsed* | integer | 1 = Pseudorange corrections have been used. |
| *crCorrUsed* | integer | 1 = Carrier range corrections have been used. |
| *doCorrUsed* | integer | 1 = Range rate (Doppler) corrections have been used. |

#### 0x0501 (*payload*) ####

Parses `0x0501` (ACK_ACK) UBX message payload.

##### Parameters #####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *payload* | blob | Yes | 2 bytes ACK_ACK message payload. |

##### Return Value #####

An integer, the 2 byte message class and ID for the ACK-ed message.

#### 0x0500 (*payload*) ####

Parses `0x0500` (ACK_NAK) UBX message payload.

##### Parameters #####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *payload* | blob | Yes | 2 bytes ACK_NAK message payload. |

##### Return Value #####

An integer, the 2 byte message class and ID for the NAK-ed message.

#### 0x0a04 (*payload*) ####

Parses `0x0a04` (MON_VER) UBX message payload.

##### Parameters #####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *payload* | blob | Yes | 40 + 30*n bytes MON_VER message payload. |

##### Return Value #####

A table.

| Key | Type | Description |
| --- | --- | --- |
| *swVersion* | string | Software Version. |
| *hwVersion* | sting | Hardware Version. |
| *exSwInfo* | array | Array of extended software info strings, if any. |

#### 0x0a09 (*payload*) ####

Parses `0x0a09` (MON_HW) UBX message payload.

##### Parameters #####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *payload* | blob | Yes | 60 bytes MON_HW message payload. |

##### Return Value #####

A table.

| Key | Type | Description |
| --- | --- | --- |
| *pinSel* | blob | Mask of Pins Set as Peripheral/PIO. |
| *pinBank* | blob | Mask of Pins Set as Bank A/B. |
| *pinDir* | blob | Mask of Pins Set as Input/Output. |
| *pinVal* | blob | Mask of Pins Value Low/High. |
| *noisePerMS* | integer | Noise Level as measured by the GPS Core. |
| *agcCnt* | integer | AGC Monitor (counts SIGHI xor SIGLO, range 0 to 8191). |
| *aStatus* | integer | Status of the Antenna Supervisor State Machine: 0 = INIT, 1 = DONTKNOW, 2 = OK, 3 = SHORT, 4 = OPEN. |
| *aPower* | integer | Current PowerStatus of Antenna: 0 = OFF, 1 = ON, 2 = DON'T KNOW. |
| *flags* | table | Table of flags *(see below)*. |
| *usedMask* | blob | Mask of Pins that are used by the Virtual Pin Manager. |
| *vp* | blob | Array of Pin Mappings for each of the 17 Physical Pins. |
| *jamInd* | integer | CW Jamming indicator, scaled: 0 = no CW jamming, 255 = strong CW jamming. |
| *pinIrq* | blob | Mask of Pins Value using the PIO Irq. |
| *pullH* | blob | Mask of Pins Value using the PIO Pull High Resistor. |
| *pullL* | blob | Mask of Pins Value using the PIO Pull Low Resistor. |

Flags Table

| Key | Type | Description |
| --- | --- | --- |
| *rtcCalib* | integer | RTC is calibrated. |
| *safeBoot* | integer | safeBoot mode: 0 = inactive, 1 = active. |
| *jammingState* | integer | output from Jamming/Interference Monitor: 0 = unknown or feature disabled, 1 = ok - no significant jamming, 2 = warning - interference visible but fix OK, 3 = critical - interference visible and no fix. |
| *xtalAbsent* | integer | RTC xtal has been determined to be absent. (not supported in protocol versions less than 18). |

#### 0x1360 (*payload*) ####

Parses `0x1360` (MGA_ACK) UBX message payload.

##### Parameters #####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *payload* | blob | Yes | 8 bytes MGA_ACK message payload. |

##### Return Value #####

A table.

| Key | Type | Description |
| --- | --- | --- |
| *type* | integer |Type of acknowledgment: 0 = The message was not used by the receiver (see infoCode field for an indication of why), 1 = The message was accepted for use by the receiver (the infoCode field will be 0). |
| *version* | integer | Message version (0x00 for this version). |
| *infoCode* | integer | Provides greater information on what the receiver chose to do with the message contents: 0 = The receiver accepted the data, 1 = The receiver doesn't know the time so can't use the data (To resolve this a UBX-MGA-INITIME_UTC message should be supplied first), 2 = The message version is not supported by the receiver, 3 = The message size does not match the message version, 4 = The message data could not be stored to the database, 5 = The receiver is not ready to use the message data, 6 = The message type is unknown. |
| *msgId* | integer | UBX message ID of the ack'ed message. |
| *msgPayloadStart* | blob | The first 4 bytes of the ack'ed message's payload. |

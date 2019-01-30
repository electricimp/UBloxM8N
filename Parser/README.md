# UbxMsgParser 1.0.0 #

This library provides a parser for UBX binary messages. For information about UBX messages, please see [the u-blox protocol specification](https://www.u-blox.com/sites/default/files/products/documents/u-blox8-M8_ReceiverDescrProtSpec_%28UBX-13003221%29_Public.pdf).

The parser is implemented as a table, so command-parsing functions can be added and existing ones easily customized. A small number of messages have been selected as a base. These commands are detailed in the [Class Methods](#class-methods) section below.

**To include this library in your project, add** `#require "UbxMsgParser.lib.nut:1.0.0"` **at the top of your code.**

## Class Usage ##

No initialization is needed to use the parser, which is implemented as a table that is accessed via the global variable *UbxMsgParser*.

There are [two helper methods](#class-methods) available to convert the integer latitude and longitude values returned by UBX methods to strings in the more common format for this data. 

The remaining slots in the parser table are identified by 16-bit integers: the UBX message class ID. For example, to parse the payload of a UBX message of type NAV_PVT, you would call:

```squirrel
local result = UbxMsgParser[0x0107](payload)
```

where *payload* is the message data and *result* is the parsed information, returned as a table.

The value of each slot is the relevant parsing function. Each parsing function takes the UBX message payload and returns a table. The parsed tables will always contain *error* and *payload* slots. If no error was encountered when parsing the payload, additional parameters will be included in the table. Users should always check the *error* value before accessing the other slots.

**Note** Squirrel only supports signed 32-bit integers. If the payload contains a 32-bit unsigned integer, the parsed table will contain a four-byte blob with the payload values. These values will be in the same order as received by the M8N (little endian).

## Class Methods ##

### getLatStr(*UBXlatitude*) ###

This method converts an integer UBX latitude value into a decimal degree latitude string, eg. `"37.3955323 N"`.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *UBXlatitude* | Integer | Yes | Latitude integer from a parsed UBX message |

#### Returns ####

String &mdash; the decimal degree latitude.

### getLonStr(*UBXlongitude*) ###

This method converts an integer UBX longitude value into a decimal degree longitude string, eg. `"122.1023164 W"`.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *UBXlongitude* | Integer | Yes | Longitude integer from a parsed UBX message |

#### Returns ####

String &mdash; the decimal degree longitude.

### 0x0107(*payload*) ###

This method parses `0x0107` (NAV_PVT) UBX message payloads.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *payload* | Blob | Yes | 100-byte NAV_PVT message payload |

#### Returns ####

Table &mdash; contains the following keys:

| Key | Type | Description |
| --- | --- | --- |
| *error* | String or `null` | Error message if a parsing error was encountered, or `null` |
| *payload* | Blob | The unparsed payload |
| *iTOW* | Blob | GPS time of week of the navigation epoch in ms (four-byte unsigned integer) |
| *year* | Integer | Year (UTC) |
| *month* | Integer | Month in range 1-12 (UTC) |
| *day* | Integer | Day of month in range 1-31 (UTC) |
| *hour* | Integer | Hour of day in range 0-23 (UTC) |
| *min* | Integer | Minute of hour in range 0-59 (UTC) |
| *sec* | Integer | Seconds of minute in range 0-60 (UTC) |
| *valid* | Table | Validity flags *([see below](#validity-flags))* |
| *tAcc* | Integer | Time accuracy estimate in ns (UTC) |
| *nano* | Integer | Fraction of second in range -1e9 to +1e9 (UTC) |
| *fixType* | Integer | GNSSfix Type:<br />0 = No fix<br />1 = Dead reckoning only<br />2 = 2D fix<br />3 = 3D fix<br />4 = GNSS plus dead reckoning combined<br />5 = Time-only fix |
| *fixStatusFlags* | Table | Fix status flags *([see below](#fix-status-flags))* |
| *numSV* | Integer | Number of satellites used |
| *lon* | Integer | Longitude in degrees |
| *lat* | Integer | Latitude in degrees |
| *height* | Integer | Height above ellipsoid in mm |
| *hMSL* | Integer | Height above mean sea level mm |
| *hAcc* | Blob | Horizontal accuracy estimate in mm (four-byte unsigned integer) |
| *vAcc* | Blob | Vertical accuracy estimate in mm (four-byte unsigned integer) |
| *velN* | Integer | NED north velocity in mm/s |
| *velE* | Integer | NED east velocity in mm/s |
| *velD* | Integer | NED down velocity in mm/s |
| *gSpeed* | Integer | Ground Speed (2D) in mm/s |
| *headMot* | Integer | Heading of motion (2D) in degrees |
| *sAcc* | Blob | Speed accuracy estimate in mm/s  (four-byte unsigned integer) |
| *headAcc* | Blob | Heading accuracy estimate (both motion and vehicle) in mm/s (four-byte unsigned integer) |
| *pDOP* | Integer | Position DOP |
| *headVeh* | Integer | Heading of vehicle (2D) in degrees |
| *magDec* | Integer | Magnetic declination in degrees |
| *magAcc* | Integer | Magnetic declination accuracy in degrees |

#### Validity Flags ####

| Key | Type | Description |
| --- | --- | --- |
| *validDate* | Bool | UTC date valid? |
| *validTime* | Bool | UTC time of day valid? |
| *fullyResolved* | Bool | UTC time of day has been fully resolved? (no seconds uncertainty) |
| *validMag* | Bool | Magnetic declination valid? |

#### Fix Status Flags ####

| Key | Type | Description |
| --- | --- | --- |
| *gnssFixOK* | Integer | 1 = Valid fix (ie. within DOP & accuracy masks) |
| *diffSoln* | Integer | 1 = Differential corrections were applied |
| *psmState* | Integer | Power Save Mode state:<br />0 = PSM is not active<br />1 = Enabled (an intermediate state before acquisition)<br />2 = Acquisition<br />3 = Tracking<br />4 = Power-optimized tracking<br />5 = Inactive |
| *headVehValid* | Integer | 1 = heading of vehicle is valid |
| *carrSoln* | Integer | Carrier phase range solution status (not supported in protocol versions less than 20):<br />0 = No carrier phase range solution<br />1 = Float solution (no fixed integer carrier phase measurements have been used to calculate the solution)<br />2 = Fixed solution (one or more fixed integer carrier phase range measurements have been used to calculate the solution) |
| *confirmedAvai* | Integer | 1 = Information about UTC Date and Time of Day validity confirmation is available (Not supported in all versions) |
| *confirmedDate* | Integer | 1 = UTC date validity could be confirmed |
| *confirmedTime* | Integer | 1 = UTC time of day could be confirmed |

### 0x0135(*payload*) ###

This method parses `0x0135` (NAV_SAT) UBX message payloads.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *payload* | Blob | Yes | 8 + 12 * n bytes of NAV_SAT message payload |

#### Returns ####

Table &mdash; contains the following keys:

| Key | Type | Description |
| --- | --- | --- |
| *error* | String or `null` | Error message if a parsing error was encountered, or `null` |
| *payload* | Blob | The unparsed payload |
| *iTOW* | Blob | GPS time of week of the navigation epoch in ms (four-byte unsigned integer) |
| *version* | Integer | Message version (1 for this version) |
| *numSvs* | Integer | Number of satellites |
| *satInfo* | Array of tables | Satellite details *([see below](#satellite-info-table-keys))* |

#### Satellite Info Table Keys ####

| Key | Type | Description |
| --- | --- | --- |
| *error* | String or `null` | Error message if a parsing error was encountered, or `null` |
| *payload* | Blob | The unparsed payload |
| *gnssId* | Integer | GNSS identifier |
| *svId* | Integer | Satellite identifier |
| *cno* | Integer | Carrier to noise ratio (signal strength) in dBHz |
| *elev* | Integer | Elevation (range &plusmn;90), unknown if out of range, in degrees |
| *azim* | Integer | Azimuth (range 0-360), unknown if elevation is out of range, in degrees |
| *prRes* | Integer | Pseudorange residual in m |
| *flags* | Table | Set of flags *([see below](#satellite-info-flags))* |

#### Satellite Info Flags ####

| Key | Type | Description |
| --- | --- | --- |
| *error* | String or `null` | Error message if a parsing error was encountered, or `null` |
| *payload* | Blob | The unparsed payload |
| *qualityInd* | Integer | Signal quality indicator:<br />0 = No signal<br />1 = Searching for signal<br />2 = Signal acquired<br />3 = Signal detected but unusable<br />4 = Code locked and time synchronized<br />5, 6, 7 = Code and carrier locked and time synchronized |
| *svUsed* | Integer | 1 = Signal in the subset specified in signal identifiers is currently being used for navigation |
| *health* | Integer | Signal health flag:<br />0 = Unknown<br />1 = Healthy<br />2 = Unhealthy |
| *diffCorr* | Integer | 1 = Differential correction data is available for this SV |
| *smoothed* | Integer | 1 = Carrier smoothed pseudorange used |
| *orbitSource* | Integer | Orbit source:<br />0 = No orbit information is available for this SV<br />1 = Ephemeris is used<br />2 = Almanac is used<br />3 = AssistNow offline orbit is used<br />4 = AssistNow autonomous orbit is used<br />5, 6, 7 = Other orbit information is used |
| *ephAvail* | Integer | 1 = Ephemeris is available for this SV |
| *almAvail* | Integer | 1 = Almanac is available for this SV |
| *anoAvail* | Integer | 1 = AssistNow offline data is available for this SV |
| *aopAvail* | Integer | 1 = AssistNow autonomous data is available for this SV |
| *sbasCorrUsed* | Integer | 1 = SBAS corrections have been used for a signal |
| *rtcmCorrUsed* | Integer | 1 = RTCM corrections have been used |
| *slasCorrUsed* | Integer | 1 = QZSS SLAS corrections have been used |
| *prCorrUsed* | Integer | 1 = Pseudorange corrections have been used |
| *crCorrUsed* | Integer | 1 = Carrier range corrections have been used |
| *doCorrUsed* | Integer | 1 = Range rate (Doppler) corrections have been used |

### 0x0501(*payload*) ###

This method parses `0x0501` (ACK_ACK) UBX message payloads.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *payload* | Blob | Yes | A two-byte ACK_ACK message payload |

#### Returns ####

Table &mdash; contains the following keys:

| Key | Type | Description |
| --- | --- | --- |
| *error* | string or `null` | Error message if a parsing error was encountered, or `null` |
| *payload* | Blob | The unparsed payload |
| *ackMsgClassId* | Integer | The two-byte message class and ID of the ACK’d message |

### 0x0500(*payload*) ###

This method parses `0x0500` (ACK_NAK) UBX message payloads.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *payload* | Blob | Yes | A two-byte ACK_NAK message payload |

#### Returns ####

Table &mdash; contains the following keys:

| Key | Type | Description |
| --- | --- | --- |
| *error* | String or `null` | Error message if a parsing error was encountered, or `null` |
| *payload* | Bblob | The unparsed payload |
| *nakMsgClassId* | Integer | The two-byte message class and ID of the NAK’d message |

### 0x0A04(*payload*) ###

This method parses `0x0a04` (MON_VER) UBX message payloads.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *payload* | Blob | Yes | 40 + 30 * n bytes of MON_VER message payload |

#### Returns ####

Table &mdash; contains the following keys:

| Key | Type | Description |
| --- | --- | --- |
| *error* | String or `null` | Error message if a parsing error was encountered, or `null` |
| *payload* | Blob | The unparsed payload |
| *swVersion* | String | The software Version |
| *hwVersion* | Sting | The hardware Version |
| *exSwInfo* | Array of strings | Extended software information strings, if any |

### 0x0A09(*payload*) ###

This method parses `0x0a09` (MON_HW) UBX message payloads.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *payload* | Blob | Yes | A 60-byte MON_HW message payload |

#### Returns ####

Table &mdash; contains the following keys:

| Key | Type | Description |
| --- | --- | --- |
| *error* | String or `null` | Error message if a parsing error was encountered, or `null` |
| *payload* | Blob | The unparsed payload |
| *pinSel* | Blob | Mask of pins set as Peripheral/PIO |
| *pinBank* | Blob | Mask of pins set as Bank A/B |
| *pinDir* | Blob | Mask of pins set as Input/Output |
| *pinVal* | Blob | Mask of pins of value Low/High |
| *noisePerMS* | Integer | Noise level as measured by the GPS core |
| *agcCnt* | Integer | AGC Monitor (counts SIGHI xor SIGLO, range 0 to 8191) |
| *aStatus* | Integer | The status of the antenna supervisor state machine:<br />0 = Initializing<br />1 = Unknown<br /> 2 = OK<br />3 = Short<br />4 = Open |
| *aPower* | Integer | The current power status of the antenna:<br />0 = Off<br />1 = On<br />2 = Unknown |
| *flags* | Table | Table of flags *([see below](#flags-table))* |
| *usedMask* | Blob | Mask of pins that are used by the Virtual Pin Manager |
| *vp* | blob | Array of pin mappings for each of the 17 physical pins |
| *jamInd* | Integer | CW Jamming indicator, scaled from 0 (no CW jamming) to 255 (strong CW jamming) |
| *pinIrq* | Blob | Mask of pins using the PIO IRQ |
| *pullH* | Blob | Mask of pins using the PIO Pull High Resistor |
| *pullL* | Blob | Mask of pins using the PIO Pull Low Resistor |

#### Flags Table ####

| Key | Type | Description |
| --- | --- | --- |
| *rtcCalib* | Integer | RTC is calibrated |
| *safeBoot* | Integer | Safe boot mode:<br />0 = Inactive<br />1 = Active |
| *jammingState* | Integer | Output from the Jamming/Interference Monitor:<br />0 = Unknown or feature disabled<br />1 = OK &mdash; no significant jamming<br />2 = Warning &mdash; interference visible but fix OK<br />3 = Critical &mdash; interference visible and no fix |
| *xtalAbsent* | integer | RTC crystal has been determined to be absent. **Note** Not supported in protocol versions less than 18 |

### 0x1360(*payload*) ###

This method parses `0x1360` (MGA_ACK) UBX message payloads.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *payload* | Blob | Yes | An eight-byte MGA_ACK message payload |

#### Returns ####

Table &mdash; contains the following keys:

| Key | Type | Description |
| --- | --- | --- |
| *error* | String or `null` | Error message if a parsing error was encountered, or `null` |
| *payload* | Blob | The unparsed payload |
| *type* | Integer | Type of acknowledgment:<br />0 = The message was not used by the receiver (see *infoCode* field for an indication of why)<br />1 = The message was accepted for use by the receiver (the *infoCode* field will be 0) |
| *version* | Integer | Message version (0x00 for this version) |
| *infoCode* | Integer | Provides greater information about what the receiver chose to do with the message contents:<br />0 = The receiver accepted the data<br />1 = The receiver doesn't know the time so can't use the data: supply a UBX-MGA-INITIME_UTC message first<br />2 = The message version is not supported by the receiver<br />3 = The message size does not match the message version<br />4 = The message data could not be stored in the database<br />5 = The receiver is not ready to use the message data<br />6 = The message type is unknown |
| *msgId* | Integer | UBX message ID of the ACK’d message |
| *msgPayloadStart* | Blob | The first four bytes of the ACK’d message’s payload |

## License ##

This library is licensed under the [MIT License](./LICENSE).
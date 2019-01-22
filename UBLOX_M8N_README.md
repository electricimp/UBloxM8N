# UBloxM8N #

UART driver for u-blox M8N GPS module.

**To add this library to your project, add** `#require "UBloxM8N.device.lib.nut:1.0.0"` **to the top of your device code.**

## Class Usage ##

### onMessage Callback ###

When a valid message is received from the M8N it will be passed to an onMessage callback if there is one. For any message only **one** callback will be triggered. If a message specific callback is available it will be used. If no message specific callback is available, the more general type specific *onNmeaMsg* or *onUbxMsg* will be used. If there are no message specific and no type specific callbacks registered, then the *defaultOnMsg* will be used.

Callback Function Details:

| Callback Name | Register Callback Type | Parameters | Parameter Description(s) |
| --- | --- | --- | --- |
| *defaultOnMsg* | UBLOX_M8N_CONST.DEFAULT_ON_MSG | 1 required, 1 optional | first parameter (req): blob/string *payload/NMEA Sentence*, second parameter (opt): integer *class-id* |
| *onUbxMsg* | UBLOX_M8N_CONST.ON_UBX_MSG | 2 required | first parameter: blob *payload*, second parameter: integer *class-id* |
| *onNmeaMsg* | UBLOX_M8N_CONST.ON_NMEA_MSG | 1 required | first parameter: string *NMEA Sentence* |
| *ubx message specific callback* | Message Class Id as an integer | 1 required  | first parameter: blob *payload* |

### Constructor: GPSUARTDriver(*uart[, bootTimeoutSec][, baudRateAtBoot]*) ###

Initializes u-blox M8N driver object. The constructor will initialize the specified hardware.uart object using the either the specified baud rate or a default baud rate of 9600 (the default baud rate specified in the u-blox data sheet).

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *uart* | string | Yes | The imp UART bus that the M8N is connected to. |
| *bootTimeoutSec* | integer/float | No | The time in seconds to wait after boot before commands are written to the M8N. Default is 1 sec. |
| *baudRateAtBoot* | integer | No | The baud rate that the M8N will default to after a cold boot. This defaults to 9600 (the default specified in the u-blox data sheet). This should not need to be changed unless a different baud rate has been stored to the M8N's flash memory. |

## Class Methods ##

### configure(*options*) ###

Use this method to configure a new uart baud rate, define the message type(s) the M8N will accept, define the message type(s) the M8N will send, and to set default message callbacks for incoming messages from the M8N. **Note:** This method will re-configure the uart bus.

#### Parameters ####

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
| *onUbxMsg* | function | `null` | A callback function that is triggered when an UBX message is received if no message specific callback is defined. *(see onMessage Callback above)* |
| *defaultOnMsg* | function | `null` | A callback function that is triggered when any fully formed NMEA sentence or UBX message is recieved from the M8N if no other callbacks are defined for that message or message type. *(see onMessage Callback above)* |

Input/Output Mode Selector Options:

| Name | Value |
| --- | --- |
| *UBLOX_M8N_MSG_MODE.UBX_ONLY* | 0x0001 |
| *UBLOX_M8N_MSG_MODE.NMEA_ONLY* | 0x0002 |
| *UBLOX_M8N_MSG_MODE.BOTH* | 0x0003 |

#### Return Value ####

None.

### enableUbxMsg(*classId, rate[, onMessage]*) ###

Enable UBX messages at the specified rate. When messages are received they will be passed to the onMessage callback. If no onMessage callback is specified messages will be passed to either onUbxMsg or defaultOnMsg callback instead. To disable messages pass a rate of 0 to this method.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *classId* | integer | Yes | The 2 byte message class and id. |
| *rate* | integer | Yes | How often, in seconds, new messages should be sent. |
| *onMessage* | function | No | A callback function for incoming messages with this class-Id. If no callback is specified one of the more general onMessage callbacks will be used. *(see onMessage Callback above)* |

#### Return Value ####

None.

### registerOnMessageCallback(*type, onMessage*) ###

Registers a message onMessage callback for incoming messages from the M8N.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *type* | string/integer | Yes | Either the UBX 2 byte message class and id, or one of the following onMessage callback types: UBLOX_M8N_CONST.DEFAULT_ON_MSG, UBLOX_M8N_CONST.ON_NMEA_MSG, UBLOX_M8N_CONST.ON_UBX_MSG |
| *onMessage* | function | Yes | A callback for incoming messages of this type. *(see onMessage Callback above)* |

#### Return Value ####

None.

### writeUBX(*classId, payload*) ###

Writes a UBX protocol packet to the M8N. Note if your command expects a response be sure you have a callback registered.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *classId* | integer | Yes | The 2 byte message class and id. |
| *payload* | blob/string | Yes | The message payload. |

#### Return Value ####

None.

### function writeNMEA(*sentence*) ###

Writes an NMEA protocol packet to the M8N.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *sentence* | string | Yes | An NMEA formatted sentence with comma separated fields. This method will add the start character, ending characters, and the check sum to the sentence if needed before writing. |

#### Return Value ####

None.

### function writeMessage(*message*) ###

Writes a message to the M8N. Message is written to uart, no headers, check sum etc are added.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *message* | blob/string | Yes | Message to write to M8N uart. |

#### Return Value ####

None.

### function calcUbxChecksum(*packet*) ###

Calculates the check sum for a UBX packet. Packet must consist of only the following: message class(1 byte), message id (1 byte), payload length (2 bytes), and payload.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *packet* | blob | Yes | Packet to calculate check sum on. |

#### Return Value ####

String, 2 byte check sum.

### function calcNMEACheckSum(*sentence*) ###

Calculates the check sum for an NMEA sentence. This method will ignore starting and ending characters if they are in the sentence that is passed in.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *sentence* | string | Yes | Sentence to calculate check sum on. |

#### Return Value ####

Integer, one byte check sum.
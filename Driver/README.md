# UBloxM8N 1.0.1 #

This library provides a driver for a [u-blox M8N GPS module](https://www.u-blox.com/en/product/neo-m8-series) connected to the host imp via UART.

**To include this library in your project, add** `#require "UBloxM8N.device.lib.nut:1.0.1"` **at the top of your device code.**

## Class Usage ##

### Received Message Callbacks ###

When a valid message is received from the M8N, it will be passed to a message callback if one has been set. For any given message, only **one** callback will be triggered &mdash; the first available in the following order:

1. If a message-specific callback, ie. one targeting a specific two-byte message class ID, has been registered, it will be used.
2. If no message-specific callback has been registered, the generic, type-specific callbacks, *onNmeaMsg* or *onUbxMsg*, will be used, depending of the type of message received.
3. If no type-specific callback has been registered, the *defaultOnMsg* callback will be used.
4. If no default callback has been registered, the message will be ignored.

Type-specific callbacks can be registered using the methods [*configure()*](#configureoptions) and/or [*registerOnMessageCallback()*](#registeronmessagecallbacktype-callback). The latter can also be used to register message-specific callbacks, as can [*enableUbxMsg()*](#enableubxmsgclassid-rate-callback).

#### Callback Parameter Details ####

| Callback&nbsp;Name | Callback&nbsp;Type&nbsp;Value | Parameters | Parameter&nbsp;Description(s) |
| --- | --- | --- | --- |
| *defaultOnMsg* | *UBLOX_M8N_CONST.DEFAULT_ON_MSG* | 1 required,<br />1 optional | 1. Blob or string, the message payload or NMEA sentence (required)<br />2. Integer, a class ID (optional) |
| *onUbxMsg* | *UBLOX_M8N_CONST.ON_UBX_MSG* | 2 required | 1. Blob, the message payload<br />2. Integer, the class ID |
| *onNmeaMsg* | *UBLOX_M8N_CONST.ON_NMEA_MSG* | 1 required | String, the message NMEA sentence |
| Message-specific callback | Message class ID as an integer | 1 required  | Blob, the message payload |

### Constructor: GPSUARTDriver(*uart[, bootTimeoutSec][, baudRateAtBoot]*) ###

The constructor instantiates and initializes the u-blox M8N driver object. The constructor will initialize the specified **hardware.uart** object using the either the specified baud rate or a default baud rate of 9600 (as specified in the u-blox data sheet).

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *uart* | String | Yes | The imp UART bus that the M8N is connected to |
| *bootTimeoutSec* | Integer or float | No | The time in seconds to wait after boot before commands are written to the M8N. Default: 1 second |
| *baudRateAtBoot* | Integer | No | The baud rate that the M8N will default to after a cold boot. This should not need to be changed unless a different baud rate has been stored to the M8N's flash memory. Default: 9600 baud |

## Class Methods ##

### configure(*options*) ###

This method can be used to set a new UART baud rate, to define the message type(s) the M8N will accept, to define the message type(s) the M8N will send, and/or to set default message callbacks for incoming messages from the M8N.

**Note** This method will re-configure the UART bus to which the M8N is connected.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *options* | Table | Yes | A table of settings used to configure the u-blox module *(see below)* |

The *options* table may contain any of the following keys:

| Key | Type | Default | Description |
| --- | --- | --- |--- |
| *baudRate* | Integer | The currently configured baud rate | The baud rate to which the UART should be set |
| *outputMode* | Integer | *UBLOX_M8N_MSG_MODE.BOTH* | The output message type. Use the enum *UBLOX_M8N_MSG_MODE* to set this *([see below](#input-and-output-mode-options))* |
| *inputMode* | Integer | *UBLOX_M8N_MSG_MODE.BOTH* | The input message type. Use the enum *UBLOX_M8N_MSG_MODE* to set this *([see below](#input-and-output-mode-options))* |
| *defaultOnMsg* | Function | `null` | A callback that is triggered when any fully formed NMEA sentence or UBX message is received and no callbacks are set for that message ID or message type *([see ‘Received Message Callbacks’, above](#received-message-callbacks))* |
| *onUbxMsg* | Function | `null` | A callback that is triggered when a UBX message is received and no message-specific callback is defined *([see ‘Received Message Callbacks’, above](#received-message-callbacks))* |
| *onNmeaMsg* | Function | `null` | A callback that is triggered when an NMEA sentence is received and no message-specific callback is defined *([see ‘Received Message Callbacks’, above](#received-message-callbacks))* |

#### Input And Output Mode Options ####

| Constant | Value |
| --- | --- |
| *UBLOX_M8N_MSG_MODE.UBX_ONLY* | 0x0001 |
| *UBLOX_M8N_MSG_MODE.NMEA_ONLY* | 0x0002 |
| *UBLOX_M8N_MSG_MODE.BOTH* | 0x0003 |

#### Returns ####

Nothing.

### enableUbxMsg(*classID, rate[, callback]*) ###

This method enables UBX messages of the specified ID to be received at the specified rate. When messages are received, they will be passed to the function passed into the *callback* parameter. If no such message-specific callback has been provided (it is optional), messages will instead be passed either to the type-specific [*onUbxMsg* callback](#received-message-callbacks) or to the generic [*defaultOnMsg* callback](#received-message-callbacks), if either have been registered.

For more information, please see [‘Received Message Callbacks’](#received-message-callbacks), above.

To disable messages, specify a rate of 0. If messaging is disabled, the callback will be de-registered.

**Note:** If using UBloxAssistNow Library an error will be thrown if this method is used to enable/disable MGA-ACK (0x1360) or MON-VER (0x0a04) messages. The payload for MON-VER message can be retrieved via UBloxAssistNow class method.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *classID* | Integer | Yes | The two-byte message class and ID |
| *rate* | Integer | Yes | How often, in seconds, new messages should be sent |
| *callback* | Function | No | A callback function for incoming messages with this class ID only. Default: `null` |

#### Returns ####

Nothing.

### registerOnMessageCallback(*IDorType, callback*) ###

This method registers a message-specific or type-specific callback that will handle messages of the specified ID or type when they are received from the M8N.

For more information, please see [‘Received Message Callbacks’](#received-message-callbacks), above.

To de-register a callback, pass `null` into the *callback* parameter.

**Note:** If using UBloxAssistNow Library an error will be thrown if this method is used to enable/disable MGA-ACK (0x1360) or MON-VER (0x0a04) messages. The payload for MON-VER message can be retrieved via UBloxAssistNow class method.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *IDorType* | String or integer | Yes | Either a UBX two-byte message class and ID (for a message-specific callback) or one of the following generic message types: *UBLOX_M8N_CONST.DEFAULT_ON_MSG*, *UBLOX_M8N_CONST.ON_NMEA_MSG*, *UBLOX_M8N_CONST.ON_UBX_MSG* |
| *callback* | Function | Yes | A function for handling incoming messages of the specified ID or type |

#### Returns ####

Nothing.

### writeUBX(*classID, payload*) ###

This method writes a UBX protocol packet to the M8N.

**Note** If your command provides a response, be sure you have a suitable callback registered.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *classID* | Integer | Yes | The two-byte message class and ID |
| *payload* | Blob or string | Yes | The message payload |

#### Returns ####

Nothing.

### writeNMEA(*sentence*) ###

This method writes an NMEA protocol packet to the M8N.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *sentence* | String | Yes | An NMEA-formatted sentence with comma-separated fields. The start character and ending characters will be added for you, as will the check sum to the sentence if one is needed |

#### Returns ####

Nothing.

### writeMessage(*message*) ###

This method writes a message to the M8N. Message is written straight to UART; no headers, check sum, etc. are added.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *message* | Blob or string | Yes | The message to write |

#### Returns ####

Nothing.

### calcUbxChecksum(*packet*) ###

This method calculates the checksum for a UBX packet. The packet must consist of only the following: message class (1 byte), message ID (1 byte), payload length (2 bytes) and the payload itself.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *packet* | Blob | Yes | Packet to be used for the checksum calculation |

#### Returns ####

String &mdash; the two-byte checksum.

### calcNmeaChecksum(*sentence*) ###

This method calculates the checksum for an NMEA sentence. It will ignore start and end characters if they have been included in the specified sentence.

#### Parameters ####

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| *sentence* | String | Yes | Sentence to be used for the checksum calculation |

#### Returns ####

Integer &mdash; a one-byte checksum.

## License ##

This library is licensed under the [MIT License](./LICENSE).
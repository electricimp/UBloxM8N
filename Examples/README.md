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

## NMEA Location ##

This example shows how to:

- configure the M8N to send and receive only NMEA messages
- register both a default callback for NMEA messages
- parse and log location data from an NMEA message

[Code](./NMEA_Location.device.nut)

## UBX and NMEA Location ##

These examples shows how to:

- configure the M8N to send and receive both UBX and NMEA messages
- use a single onMessage callback to process data
- parse and log location data

[Code](./UBX_NMEA_Location.device.nut)

# Examples #

These examples demonstrate how you can use the UBloxM8N driver with both the UbxMsgParser library (for parsing UBX messages) and GPSParser library (for parsing NMEA sentences). All of the examples run on the device only.

## UBX Location ##

This example shows how you can:

- Increase the UART baud rate.
- Configure the M8N to send and receive only UBX messages.
- Register both a default callback for UBX messages and a number of message-specific callbacks.
- Enable and disable navigation messaging.
- Get the module's software version by sending a raw command.
- Parse and log messages received by the various callbacks.

[View the example here](./UBX_Location.device.nut)

## NMEA Location ##

This example shows how you can:

- Configure the M8N to send and receive NMEA messages only.
- Register both a default callback for NMEA messages and a message-specific callback.
- Parse and log location data from an NMEA message.

[View the example here](./NMEA_Location.device.nut)

## UBX and NMEA Location ##

This example shows how you can:

- Configure the M8N to send and receive both UBX and NMEA messages.
- Use a single callback to process incoming data.
- Parse and log location data.

[View the example here](./UBX_NMEA_Location.device.nut)

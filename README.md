# UBloxM8N #

Electric Imp offers two libraries to support the [u-blox M8N GPS module](https://www.u-blox.com/en/product/neo-m8-series): a device-side driver class, and a message parser. The libraries are based on the commands defined in the [u-blox receiver protocol specification](https://www.u-blox.com/sites/default/files/products/documents/u-blox8-M8_ReceiverDescrProtSpec_%28UBX-13003221%29_Public.pdf).

## [UBloxM8N](./Driver) ##

This is a UART driver for u-blox M8N GPS module.

[Documentation](./Driver/README.md)

[Library source code](./Driver/UBloxM8N.device.lib.nut)

**To include this library in your project, add** `#require "UBloxM8N.device.lib.nut:1.0.0"` **at the top of your device code.**

## [UbxMsgParser](./Parser) ##

This is a parser for UBX binary messages. For information about UBX message, please see the [u-blox receiver protocol specification](https://www.u-blox.com/sites/default/files/products/documents/u-blox8-M8_ReceiverDescrProtSpec_%28UBX-13003221%29_Public.pdf).

The parser is implemented as a table, so parsing functions can be added and customized. A small number of messages have been selected as a base. These commands are detailed in the documentation.

[Documentation](./Parser/README.md)

[Library source code](./Parser/UbxMsgParser.lib.nut)

**To include this library in your project, add** `#require "UbxMsgParser.lib.nut:1.0.0"` **at the top of your code.**

## [Examples](./Examples) ##

These examples show how to use the UBloxM8N driver, with both the UbxMsgParser (for parsing UBX messages) and GPSParser (for parsing NMEA sentences). All examples run on the device only.

[UBX Location Code](./Examples/UBX_Location.device.nut)

[NMEA Location Code](./Examples/NMEA_Location.device.nut)

[General Location Code](./Examples/UBX_NMEA_Location.device.nut)

## License ##

These libraries are licensed under the [MIT License](./LICENSE).
# UBloxM8N #

Electric Imp offers two libraries to support the UBLOX M8N GPS module: a device-side driver class, and a parser. The libraries are based on the commands as defined by [Reciever Description Including Protocol Specification document](https://www.u-blox.com/sites/default/files/products/documents/u-blox8-M8_ReceiverDescrProtSpec_%28UBX-13003221%29_Public.pdf).

## UBloxM8N ##

UART driver for u-blox M8N GPS module.

[Documentation](./UBLOX_M8N_README.md)

[Code](./UBloxM8N.device.lib.nut)

**To add this library to your project, add** `#require "UBloxM8N.device.lib.nut:1.0.0"` **to the top of your device code.**

## UbxMsgParser ##

Parser for UBX binary messages. For information about UBX message  see [Reciever Description Including Protocol Specification document](https://www.u-blox.com/sites/default/files/products/documents/u-blox8-M8_ReceiverDescrProtSpec_%28UBX-13003221%29_Public.pdf).

This parser is a table, so command parsing functions can be added and customized. A small number of messages have been selected as a base. These commands are detailed in the documentation.

[Documentation](./UBX_MSG_PARSER_README.md)

[Code](./UbxMsgParser.lib.nut)

**To add this library to your project, add** `#require "UbxMsgParser.lib.nut:1.0.0"` **to the top of your code.**

## Examples ##

Basic usage examples.

## License ##

These libraries are licensed under the [MIT License](./LICENSE).
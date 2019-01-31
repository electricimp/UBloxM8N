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

class StubbedUart {

    _cb = null;
    _br = null;
    rPtr = 0;
    _rBuff = null;
    _wBuff = "";

    // API methods
    // -------------------------------------------------

    function configure(baudRate, wordSize, parity, stopBits, ctsRts, callback) {
        _cb = callback;
        _br = baudRate;
        // NOTE: Do not reset write buffer when configuring - only reset on clearWriteBuffer
        // This allows us to test commands in the UBX Driver configure method.
    }

    function flush() {
        // Not needed since we are not actually sending anything down the wire
    }

    function write(data) {
        // Stores all incoming data as a string
        // server.log(data);
        _wBuff += data.tostring();
    }

    function read() {
        if (_rBuff == null || _rBuff.len() == 0 || rPtr >= _rBuff.len()) {
            _rBuff = null;
            rPtr = 0;
            return -1;
        }

        return _rBuff[rPtr++];
    }

    // Custom test helpers
    // -------------------------------------------------

    // Writes data to read buffer and triggers callback
    function setSyncReadBuffer(data) {
        switch(typeof data) {
            case "string":
                _rBuff = blob(data.len());
                _rBuff.writestring(data);
                if (_cb) _cb();
                break;
            case "blob":
                _rBuff = data;
                if (_cb) _cb();
                break;
        }
    }

    function setAsyncReadBuffer(data) {
        local tod = typeof data;
        if (!(tod == "string" || tod == "blob")) return;

        // Update read buffer size
        if (_rBuff == null) {
            _rBuff = blob(data.len());
        } else {
            _rBuff.seek(0, 'e');
            _rBuff.resize(_rBuff.len() + data.len());
        }

        // Append data
        switch(tod) {
            case "string":
                _rBuff.writestring(data);
                break;
            case "blob" :
                _rBuff.writeblob(data);
                break;
        }

        // Move pointer to next read
        _rBuff.seek(rPtr, 'b');

        server.log(_rBuff);

        // Trigger callback
        if (_cb) imp.wakeup(0, _cb);
    }

    function clearReadBuffer() {
        _rBuff = null;
    }

    // Returns write buffer
    function getWriteBuffer() {
        return _wBuff;
    }

    function clearWriteBuffer() {
        _wBuff = "";
    }
}
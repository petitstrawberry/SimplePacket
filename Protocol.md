# SimplePacket Protocol Specification (Version 1.0)

This document describes the SimplePacket Protocol, which is a simple protocol for encoding and decoding frames of data. [日本語](Protocol_ja.md)

## Packet

A `Packet` is a unit of data with the following structure:

- **type**: 1 byte (UInt8)
- **length**: 2 bytes (16-bit unsigned integer, little-endian)
- **payload**: N bytes (data payload)

### Structure

| Field   | Size   | Description                                 |
| ------- | ------ | ------------------------------------------- |
| type    | 1 byte | Indicates the type of the packet            |
| length  | 2 bytes| Indicates the length of the payload (little-endian) |
| payload | N bytes| Data payload                                |

### EOF Packet

The EOF (End of Frame) packet is a special packet that indicates the end of a frame. It has the following structure:

- **type**: 0
- **length**: 0
- **payload**: empty

The EOF packet is used to terminate a frame.

## Frame

A `Frame` is a unit of data composed of multiple `Packets`. A frame must end with an EOF packet.

### Structure

A frame is composed as follows:

1. One or more `Packets`
2. EOF Packet (a packet with type 0)

### Decoding

The steps to decode a frame are as follows:

1. If the length of the data is less than 2 bytes, throw a `FrameDecoderError.invalidFrame` error.
2. Read the data byte by byte and generate `Packets`.
3. If the type of a `Packet` is 0, consider it the end of the frame.
4. If the length of the data is less than 2 bytes, throw a `FrameDecoderError.invalidFrame` error.
5. Read the length field of the `Packet` to get the length of the payload.
6. Read the payload.
7. Once decoding is complete, return an array of `Packets`.

## Encoding

The steps to encode a frame are as follows:

1. Convert each `Packet`'s type, length, and payload to a byte sequence in order.
2. After converting all `Packets` to byte sequences, add an EOF Packet (a packet with type 0).
3. Return the byte sequence.

### Encoding Example

1. If a `Packet` has a type of 1, a length of 3, and a payload of "abc", the byte sequence will be as follows:
   - type: 0x01
   - length: 0x03 0x00 (little-endian)
   - payload: 0x61 0x62 0x63 (ASCII codes for "abc")

2. Adding an EOF Packet results in the final byte sequence:
   - 0x01 0x03 0x00 0x61 0x62 0x63 0x00 0x00 0x00

This byte sequence represents the encoded frame.
//
//  Packet.swift
//  SimplePacket
//
//  Created by petitstrawberry on 2025/02/04.
//

import Foundation

/// PacketDecoderError is an error that occurs when decoding a packet
public enum PacketDecoderError: Error {
    /// The packet is invalid
    case invalidPacket
    /// The payload is invalid
    case invalidPayload
}

/// Packet is a unit of data
/// A packet is a object with the following structure:
/// - 1 byte for the type
/// - 2 bytes for the length (16bit unsigned integer in little-endian byte order)
/// - N bytes for the payload
public struct Packet: Equatable {
    public let type: UInt8
    public let length: UInt16
    public let payload: Data

    public init(type: UInt8, payload: Data) {
        self.type = type
        self.length = UInt16(payload.count)
        self.payload = payload
    }

    /// Encode the packet to data
    /// - Returns: The encoded data
    public func encode() -> Data {
        var data = Data()
        data.append(type)
        data.append(UInt8(length & 0xFF))
        data.append(UInt8(length >> 8))
        data.append(payload)
        return data
    }

    /// Decode one packet from the head of the data
    /// - Parameter data: The data to decode
    /// - Returns: The decoded packet
    /// - Throws: PacketDecoderError.invalidPacket if the packet is invalid
    /// - Throws: PacketDecoderError.invalidPayload if the payload is invalid
    /// - Note: This method is the inverse of `encode()`
    public static func decode(from data: Data) throws -> Packet {
        var data = data
        guard data.count >= 3 else {
            throw PacketDecoderError.invalidPacket
        }
        let type = data.removeFirst()
        let length = UInt16(data.removeFirst()) | UInt16(data.removeFirst() << 8)
        guard data.count >= Int(length) else {
            throw PacketDecoderError.invalidPayload
        }
        let payload = data.prefix(Int(length)).map { $0 }
        return Packet(type: type, payload: Data(payload))
    }

    /// EOF is a special packet type that indicates the end of the frame
    /// It is used to terminate the frame
    /// The type of EOF is 0
    /// The length of EOF is 0
    /// The payload of EOF is empty
    /// - Returns: A packet with type 0, length 0, and empty payload
    /// - Note: This is a convenience method to create an EOF packet
    public static var EOF: Packet {
        return Packet(type: 0, payload: Data())
    }
}

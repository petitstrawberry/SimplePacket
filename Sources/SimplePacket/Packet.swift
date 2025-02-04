//
//  Packet.swift
//  SimplePacket
//
//  Created by petitstrawberry on 2025/02/04.
//

import Foundation

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

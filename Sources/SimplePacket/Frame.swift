//
//  Frame.swift
//  SimplePacket
//
//  Created by petitstrawberry on 2025/02/04.
//

import Foundation

/// Frame is a collection of packets
/// A frame is a sequence of Packet objects.
/// The frame is terminated by an EOF packet.
public typealias Frame = [Packet]

/// FrameDecoderError is an error that occurs when decoding a frame
public enum FrameDecoderError: Error {
    /// The frame is invalid
    case invalidFrame
    /// The payload is invalid
    case invalidPayload
    /// The EOF packet is not found
    case eofNotFound
}

extension Frame {
    /// Decode a frame from data
    /// - Parameter data: The data to decode
    /// - Returns: The decoded frame
    /// - Throws: FrameDecoderError.invalidFrame if the frame is invalid
    /// - Throws: FrameDecoderError.invalidPayload if the payload is invalid
    /// - Note: The frame is must be terminated by an EOF packet
    public static func decode(from data: Data) throws -> Frame {
        var data = data
        var packets: [Packet] = []

        guard data.count >= 2 else {
            throw FrameDecoderError.invalidFrame
        }

        while data.count > 0 {
            let type = data.removeFirst()
            // If the type is 0, it means the end of the frame
            if type == 0 {
                break
            }
            if data.count < 2 {
                throw FrameDecoderError.invalidFrame
            }
            let length = UInt16(data.removeFirst()) | UInt16(data.removeFirst() << 8)
            if data.count < Int(length) {
                throw FrameDecoderError.invalidPayload
            }
            let payload = data.prefix(Int(length)).map { $0 }
            data.removeFirst(Int(length))
            packets.append(Packet(type: type, payload: Data(payload)))
        }
        return packets
    }

    /// Encode the frame to data
    /// - Returns: The encoded data
    /// - Throws: An error if the frame cannot be encoded
    /// - Note: The frame is terminated by an EOF packet
    /// - Note: This method is the inverse of `decode(from:)`
    public func encode() throws -> Data {
        var data = Data()
        for packet in self {
            data.append(packet.type)
            data.append(UInt8(packet.length & 0xff))
            data.append(UInt8((packet.length >> 8) & 0xff))
            data.append(packet.payload)
        }
        let eof = Packet.EOF
        data.append(eof.type)
        data.append(UInt8(eof.length & 0xff))
        data.append(UInt8((eof.length >> 8) & 0xff))
        return data
    }
}

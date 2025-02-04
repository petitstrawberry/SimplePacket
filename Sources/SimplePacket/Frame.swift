//
//  Frame.swift
//  SimplePacket
//
//  Created by petitstrawberry on 2025/02/04.
//

import Foundation

public typealias Frame = [Packet]

public enum FrameDecoderError: Error {
    case invalidFrame
    case invalidPayload
}

extension Frame {

    public static func decode(from data: Data) throws -> Frame {
        var data = data
        var packets: [Packet] = []

        guard data.count >= 3 else {
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

    public func encode() throws -> Data {
        var data = Data()
        for packet in self {
            data.append(packet.type)
            data.append(UInt8(packet.length & 0xff))
            data.append(UInt8((packet.length >> 8) & 0xff))
            data.append(packet.payload)
        }
        data.append(0)
        return data
    }
}
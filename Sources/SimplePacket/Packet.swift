//
//  Packet.swift
//  SimplePacket
//
//  Created by petitstrawberry on 2025/02/04.
//

import Foundation

public struct Packet: Equatable {
    public let type: UInt8
    public let length: UInt16
    public let payload: Data

    public init(type: UInt8, payload: Data) {
        self.type = type
        self.length = UInt16(payload.count)
        self.payload = payload
    }
}

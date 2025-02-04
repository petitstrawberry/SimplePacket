import Testing
import Foundation
@testable import SimplePacket

@Test func decode() async throws {
    let data = Data([0x01, 0x03, 0x00, 0x01, 0x02, 0x03, 0x02, 0x02, 0x00, 0x01, 0x02, 0x00, 0x00, 0x00])
    let packets = try Frame.decode(from: data)
    #expect(packets.count == 2)
    #expect(packets[0].type == 0x01)
    #expect(packets[0].length == 0x03)
    #expect(packets[0].payload == Data([0x01, 0x02, 0x03]))
    #expect(packets[1].type == 0x02)
    #expect(packets[1].length == 0x02)
    #expect(packets[1].payload == Data([0x01, 0x02]))
}

@Test func encode() async throws {
    let frame = [
        Packet(type: 0x01, payload: Data([0x01, 0x02, 0x03])),
        Packet(type: 0x02, payload: Data([0x01, 0x02]))
    ] as Frame
    let data = try frame.encode()
    #expect(data == Data([0x01, 0x03, 0x00, 0x01, 0x02, 0x03, 0x02, 0x02, 0x00, 0x01, 0x02, 0x00, 0x00, 0x00]))
}

@Test func encodeDecode() async throws {
    let packets = [
        Packet(type: 0x01, payload: Data([0x01, 0x02, 0x03])),
        Packet(type: 0x02, payload: Data([0x01, 0x02]))
    ] as Frame
    let data = try packets.encode()
    let decodedPackets = try Frame.decode(from: data)
    #expect(decodedPackets == packets)
}

@Test func invalidFrame() async {
    let data = Data([0x01, 0x03, 0x00, 0x01, 0x02, 0x02, 0x02, 0x00, 0x01, 0x02])
    do {
        _ = try Frame.decode(from: data)
        Issue.record("Expected an error")
    } catch FrameDecoderError.invalidFrame {
        // Expected
    } catch {
        Issue.record("Unexpected error: \(error)")
    }
}

@Test func invalidPayload() async {
    let data = Data([0x01, 0x03, 0x00, 0x01, 0x02, 0x03, 0x02, 0x02, 0x00, 0x01])
    do {
        _ = try Frame.decode(from: data)
        Issue.record("Expected an error")
    } catch FrameDecoderError.invalidPayload {
        // Expected
    } catch {
        Issue.record("Unexpected error: \(error)")
    }
}

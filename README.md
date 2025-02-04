# SimplePacket

SimplePacket is a simple data frame protocol.
For details on the protocol, refer to [Protocol.md](Protocol.md).

This repository contains the Swift Package implementation of SimplePacket.
This document explains this package.

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/petitstrawberry/SimplePacket.git", from: "1.0.0")
]
```

## Usage

```swift
import SimplePacket

// Define your Codable and Equatable structs
struct User: Codable, Equatable {
    let id: Int
    let name: String
}

struct Product: Codable, Equatable {
    let id: Int
    let price: Double
}

// Create instances of your structs
let user = User(id: 1, name: "Alice")
let product = Product(id: 2, price: 19.99)

// Encode the structs into packets
let userData = try JSONEncoder().encode(user)
let productData = try JSONEncoder().encode(product)

let packets = [
    Packet(type: 0x01, payload: userData),
    Packet(type: 0x02, payload: productData)
] as Frame

// Encode the frame into data
let encodedData = try packets.encode()

// Decode the data back into packets
let decodedPackets = try Frame.decode(from: encodedData)

// Decode the packets back into structs
try decodedPackets.forEach { packet in
    switch packet.type {
    case 0x01:
        let decodedUser = try JSONDecoder().decode(User.self, from: packet.payload)
        print(decodedUser)
    case 0x02:
        let decodedProduct = try JSONDecoder().decode(Product.self, from: packet.payload)
        print(decodedProduct)
    default:
        break
    }
}
```
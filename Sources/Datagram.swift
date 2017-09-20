//
//  Datagram.swift
//  SimpleDatagramProtocol
//
//  Created by Alexandre Lopoukhine on 17/07/2017.
//  Copyright © 2017 Snips. All rights reserved.
//

import Foundation

public final class Datagram: Equatable {

    public struct Header {

        static let byteCount = 9

        let key: UInt8
        let offset: UInt32
        let messageLength: UInt32
    }

    public let header: Header
    public let payload: Data.SubSequence

    public init(header: Header, payload: Data.SubSequence) {
        self.header = header
        self.payload = payload
    }
}

public func == (lhs: Datagram.Header, rhs: Datagram.Header) -> Bool {
    return lhs.key
        == rhs.key
        && lhs.messageLength
        == rhs.messageLength
        && lhs.offset
        == rhs.offset
}

public func == (lhs: Datagram, rhs: Datagram) -> Bool {
    return lhs.header
        == rhs.header
        && lhs.payload
        == rhs.payload
}

extension Datagram {

    public static func decode(_ data: Data) -> Datagram? {
        guard Header.byteCount < data.count else { return nil }

        var offset: UInt32 = 0
        for index in (0 ..< 4).reversed() {
            offset <<= 8
            offset += UInt32(data[1 + index])
        }

        var messageLength: UInt32 = 0
        for index in (0 ..< 4).reversed() {
            messageLength <<= 8
            messageLength += UInt32(data[5 + index])
        }

        return Datagram(
            header: Header(key: data[0], offset: offset, messageLength: messageLength),
            payload: data[9..<data.count]
        )
    }

    public var encoded: Data {
        var data = Data(capacity: Header.byteCount + payload.count)

        data.append(header.key)

        var offset = header.offset
        for _ in 0 ..< 4 {
            data.append(UInt8(truncatingIfNeeded: offset))
            offset >>= 8
        }

        var messageLength = header.messageLength
        for _ in 0 ..< 4 {
            data.append(UInt8(truncatingIfNeeded: messageLength))
            messageLength >>= 8
        }

        data.append(payload)
        
        return data
    }
}

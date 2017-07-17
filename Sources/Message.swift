//
//  Message.swift
//  SimpleDatagramProtocol
//
//  Created by Alexandre Lopoukhine on 17/07/2017.
//  Copyright © 2017 Snips. All rights reserved.
//

import Foundation

public final class Message: Equatable {
    public let key: UInt8
    public let data: Data

    public init(key: UInt8, data: Data) {
        self.key = key
        self.data = data
    }
}

public func == (lhs: Message, rhs: Message) -> Bool {
    return lhs.key
        == rhs.key
        && lhs.data
        == rhs.data
}

extension Message {

    public final class DatagramView {

        let message: Message
        let datagramMaxSize: Int

        let payloadMaxSize: Int

        public let endIndex: Int

        public var startIndex: Int {
            return 0
        }

        init(message: Message, datagramMaxSize: Int) {
            self.message = message
            self.datagramMaxSize = datagramMaxSize
            self.payloadMaxSize = datagramMaxSize - Datagram.Header.byteCount
            if 0 == message.data.count % payloadMaxSize {
                self.endIndex = message.data.count / payloadMaxSize
            } else {
                self.endIndex = 1 + message.data.count / payloadMaxSize
            }
        }
    }

    public func datagrams(datagramMaxSize: Int) -> DatagramView {
        return DatagramView(message: self, datagramMaxSize: datagramMaxSize)
    }
}

extension Message.DatagramView: RandomAccessCollection {

    public subscript(index: Int) -> Datagram {
        let offset = index * payloadMaxSize
        let end = Swift.min(offset + payloadMaxSize, message.data.count)

        return Datagram(
            header: Datagram.Header(
                key: message.key,
                offset: UInt32(offset),
                messageLength: UInt32(message.data.count)
            ),
            payload: message.data[offset ..< end]
        )
    }
}

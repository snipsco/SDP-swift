//
//  MessageReceiver.swift
//  SimpleDatagramProtocol
//
//  Created by Alexandre Lopoukhine on 17/07/2017.
//  Copyright © 2017 Snips. All rights reserved.
//

import Foundation

private final class MessageBuilder {

    private(set) var remainingIndices: IndexSet
    private(set) var data: Data
    let onComplete: (Data) -> ()

    init(messageLength: Int, onComplete: @escaping (Data) -> ()) {
        self.remainingIndices = IndexSet(integersIn: 0 ..< messageLength)
        self.data = Data(count: messageLength)
        self.onComplete = onComplete
    }

    func insert(_ payload: Data.SubSequence, offset: Int) {
        let subrange = offset ..< (offset + payload.count)
        data.replaceSubrange(subrange, with: payload)
        remainingIndices.remove(integersIn: subrange)
        guard remainingIndices.isEmpty else { return }
        onComplete(data)
    }
}

public final class MessageManager {

    public enum Error: Swift.Error {
        case invalidDatagram
    }

    public var onMessage: (Message) -> ()
    fileprivate var builders: [UInt8:MessageBuilder] = [:]

    public init(onMessage: @escaping (Message) -> ()) {
        self.onMessage = onMessage
    }

    public func process(datagramData: Data) throws {
        guard let datagram = Datagram.decode(datagramData) else {
            throw Error.invalidDatagram
        }

        let key = datagram.header.key
        let messageLength = Int(datagram.header.messageLength)

        let builder = builders[key] ?? MessageBuilder(messageLength: messageLength) { data in
            self.builders[key] = nil
            print("\(Date()) -- Received last message with key: \(key)")
            self.onMessage(Message(key: key, data: data))
        }

        builder.insert(datagram.payload, offset: Int(datagram.header.offset))

        guard !builder.remainingIndices.isEmpty, nil == builders[key] else { return }

        // If this is the first datagram, and there is more data to come
        print("\(Date()) -- Received first message with key: \(key)")
        builders[key] = builder
    }
}

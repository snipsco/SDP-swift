//
//  SimpleDatagramProtocolTests.swift
//  Snips
//
//  Created by Sasha Lopoukhine on {TODAY}.
//  Copyright © 2017 Snips. All rights reserved.
//

import Foundation
import XCTest
import SimpleDatagramProtocol

private struct ByteCollection: RandomAccessCollection {

    let startIndex: Int = 0
    let endIndex: Int

    init(count: Int) {
        self.endIndex = count
    }

    subscript(index: Int) -> UInt8 {
        get {
            return UInt8(truncatingIfNeeded: index)
        }
    }
}

class SimpleDatagramProtocolTests: XCTestCase {

    func testEmptyFail() {
        let data = Data()

        let datagram = Datagram.decode(data)

        XCTAssertNil(datagram)
    }

    func testSmall() {
        let message = Message(key: 0, data: Data([0]))

        var reconstructed: Message?
        let manager = MessageManager { message in
            reconstructed = message
        }

        for datagram in message.datagrams(datagramMaxSize: 20) {
            try! manager.process(datagramData: datagram.encoded)
        }

        XCTAssertEqual(message, reconstructed)
    }

    func testMedium() {
        let message = Message(key: 0, data: Data(0 ..< 11))

        var reconstructed: Message?
        let manager = MessageManager { message in
            reconstructed = message
        }

        for datagram in message.datagrams(datagramMaxSize: 20) {
            try! manager.process(datagramData: datagram.encoded)
        }

        XCTAssertEqual(message, reconstructed)
    }

    func testLarge() {
        let message = Message(key: 0, data: Data(0 ..< 100))

        var reconstructed: Message?
        let manager = MessageManager { message in
            reconstructed = message
        }

        for datagram in message.datagrams(datagramMaxSize: 20) {
            try! manager.process(datagramData: datagram.encoded)
        }

        XCTAssertEqual(message, reconstructed)
    }

    func testVeryLarge() {
        let message = Message(key: 0, data: Data(ByteCollection(count: 5000)))

        var reconstructed: Message?
        let manager = MessageManager { message in
            reconstructed = message
        }

        for datagram in message.datagrams(datagramMaxSize: 182) {
            try! manager.process(datagramData: datagram.encoded)
        }

        XCTAssertEqual(message, reconstructed)
    }

    func testFailVeryLarge() {
        let message = Message(key: 0, data: Data(ByteCollection(count: 5000)))

        var reconstructed: Message?
        let manager = MessageManager { message in
            reconstructed = message
        }

        for datagram in message.datagrams(datagramMaxSize: 182) {
            try! manager.process(datagramData: datagram.encoded)
        }

        guard let reconstructedData = reconstructed?.data else {
            XCTFail("Did not reconstruct message")
            return
        }

        var messageDataPrime = message.data
        messageDataPrime[10] = 1
        XCTAssertNotEqual(messageDataPrime, reconstructedData)
    }

    func testThrowMesageTooSmall() {
        let manager = MessageManager { message in }

        let datagramData = Data(0 ..< 8)
        XCTAssertThrowsError(try manager.process(datagramData: datagramData))
    }

    func testThrowMesagePayloadZero() {
        let manager = MessageManager { message in }

        let datagramData = Data(0 ..< 9)
        XCTAssertThrowsError(try manager.process(datagramData: datagramData))
    }
}

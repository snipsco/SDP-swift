# SDP-swift

Swift reference implementation for Simple Datagram Protocol.

## Simple Datagram Protocol

The Simple Datagram Protocol is designed to cricumvent the limitations of Bluetooth Low Energy.
The BLE protocol initially allowed for packets carrying 21 bytes of information, eventually optionally extending this to 183.
If you need to pass larger amounts of information, you need to have a way to split the bytes into chunks that can fit into these packets, and be reassembled later.
The Simple Datagram Protocol defines a structure for such packets into which the data can be split, and from which the original can be recovered.

An SDP packet has the following structure:

N is the negotiated packet size, in bytes.

| Key |   Offset   |   Total   |             Payload            |
|:---:|:----------:|:---------:|:------------------------------:|
|  1  |      4     |     4     |              N - 9             |

The Offset and Total fields are defined as little-endian unsigned integers of length 4 bytes.
The first specifies the offset, in bytes, of the payload in the original byte sequence.
The second specifies the total number of bytes to be received. 

There are no built-in methods for recovery from packet loss.
This would need to be negociated by a higher-level protocol.

//
//  OrderInput.swift
//  SocketChatCommendLine
//
//  Created by 黄穆斌 on 2017/4/23.
//  Copyright © 2017年 myron. All rights reserved.
//
/*
import Foundation

// String(data: FileHandle.standardInput.availableData, encoding: String.Encoding.ascii)
class OrderInput {
    
    class func socket_type() -> Socket.SocketType {
        enum Input_type: String {
            case tcp_server0 = "tcp server\n"
            case tcp_server1 = "ts\n"
            case tcp_client0 = "tcp client\n"
            case tcp_client1 = "tc\n"
            case udp_server0 = "udp server\n"
            case udp_server1 = "us\n"
            case udp_client0 = "udp client\n"
            case udp_client1 = "uc\n"
        }
        print("What do you want to create the socket type?")
        print("* TCP Server (tcp server / ts)")
        print("* TCP Client (tcp client / tc)")
        print("* UDP Server (udp server / us)")
        print("* UDP Client (udp client / uc)")
        
        var type: Socket.SocketType?
        while type == nil {
            print("Please input the type : ")
            if let input = String(data: FileHandle.standardInput.availableData, encoding: String.Encoding.ascii) {
                if let i_type = Input_type.init(rawValue: input) {
                    switch i_type {
                    case .tcp_server0, .tcp_server1:
                        type = Socket.SocketType.tcp_server
                    case .tcp_client0, .tcp_client1:
                        type = Socket.SocketType.tcp_client
                    case .udp_server0, .udp_server1:
                        type = Socket.SocketType.udp_server
                    case .udp_client0, .udp_client1:
                        type = Socket.SocketType.udp_client
                    }
                }
            }
        }
        return type!
    }
    
    class func input_port() -> Int32 {
        var port: Int32?
        while port == nil {
            print("Please input the port : ")
            if var input = String(data: FileHandle.standardInput.availableData, encoding: String.Encoding.ascii) {
                input.remove(at: input.index(before: input.endIndex))
                if let port_i = Int32(input) {
                    port = port_i
                }
            }
        }
        return port!
    }
    
    class func input_address() -> String {
        var address: String?
        while address == nil {
            print("Please input the Address : ")
            if var input = String(data: FileHandle.standardInput.availableData, encoding: String.Encoding.ascii) {
                input.remove(at: input.index(before: input.endIndex))
                if input.match(pattern: "^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$") {
                    address = input
                }
            }
        }
        return address!
    }
    
    class func conversation_type() -> Conversation {
        var type: Conversation?
        while type == nil {
            print("Please input the type (read / send / readsend) : ")
            if let input = String(data: FileHandle.standardInput.availableData, encoding: String.Encoding.ascii) {
                switch input {
                case "read":
                    type = Conversation.only_read
                case "send":
                    type = Conversation.only_send
                case "readsend":
                    type = Conversation.read_send
                default:
                    break
                }
            }
        }
        return type!
    }
    
}
*/

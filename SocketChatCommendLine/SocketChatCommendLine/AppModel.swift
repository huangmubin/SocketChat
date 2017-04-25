//
//  AppModel.swift
//  SocketChatCommendLine
//
//  Created by 黄穆斌 on 2017/4/23.
//  Copyright © 2017年 myron. All rights reserved.
//
/*
import Foundation

enum Conversation {
    case select
    case only_read
    case only_send
    case read_send
}

enum Status {
    // Deploy App Type
    case deploy
    // Change the Socket Address and Port
    case change
    // Conversation
    case conversation(Conversation)
    // close
    case close
}

class App {
    
    var type: Socket.SocketType = Socket.SocketType.tcp_server
    var status: Status = .deploy
    var local: Socket = Socket()
    var remote: Socket = Socket()
    
}

extension App {
    
    func socket_connect() {
        while true {
            do {
                switch type {
                case .tcp_server:
                    print("Start to create the tcp server socket.")
                    local.port = OrderInput.input_port()
                    local.address = Socket.host()
                    print("Try to create and bind socket (\(local.address):\(local.port))")
                    try local.tcp_server(port: local.port)
                    print("Start to accept the client.")
                    remote = try local.accept(time: 0)
                    print("Accpet the client (\(remote.address):\(remote.port)) success.")
                    
                    status = .conversation(.select)
                case .tcp_client:
                    print("Start to create the tcp client socket.")
                    local.port = 99999
                    local.address = Socket.host()
                    remote.address = OrderInput.input_address()
                    remote.port = OrderInput.input_port()
                    print("Try to connect the tcp server (\(remote.address):\(remote.port))")
                    try remote.tcp_client(port: remote.port, address: remote.address)
                    print("Connect the server (\(remote.address):\(remote.port)) success.")
                    
                    status = .conversation(.select)
                case .udp_server:
                    break
                case .udp_client:
                    break
                }
            } catch {
                print("Error: connect error in \(error)")
            }
        }
    }
    
}
*/

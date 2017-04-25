//
//  App.swift
//  SocketChatCommendLine
//
//  Created by 黄穆斌 on 2017/4/24.
//  Copyright © 2017年 myron. All rights reserved.
//

import Foundation

let app = App()
class App {
    
    func run(model: Model) {
        while true {
            connect(model)
            loop(model)
        }
    }
    
    func connect(_ model: Model) {
        while true {
            do {
                let socketInfo = user_socket_info()
                user_address_info(type: socketInfo, model: model)
                switch socketInfo {
                case .tcp_server:
                    print("Try to create the tcp server socket in \(model.local.address):\(model.local.port).")
                    try model.local.tcp_server(port: model.local.port)
                    print("Try to accpet the tcp client.")
                    model.remote = try model.local.accept(time: 0)
                    print("Accept client \(model.remote.address):\(model.remote.port) success;")
                    model.local.type = .tcp_server
                    model.remote.type = .tcp_client
                    return
                case .tcp_client:
                    print("Try to connect the tcp server socket in \(model.remote.address):\(model.remote.address).")
                    try model.remote.tcp_client(
                        port: model.remote.port,
                        address: model.remote.address
                    )
                    print("Connect server \(model.remote.address):\(model.remote.port) success.")
                    model.remote.type = .tcp_client
                    model.local.type = .tcp_server
                    return
                case .udp_server:
                    print("Try to create the udp server socket in \(model.local.address):\(model.local.port).")
                    try model.local.udp_server(port: model.local.port)
                    print("Try to open the socket's broadcast.")
                    try model.local.broadcast(isOpen: true)
                    print("Create the udp server socket success")
                    model.local.type = .udp_server
                    model.remote.type = .udp_client
                    return
                case .udp_client:
                    print("Try to create the udp client socket in \(model.local.address):\(model.local.port).")
                    try model.local.udp_client()
                    print("Try to open the socket's broadcast.")
                    try model.local.broadcast(isOpen: true)
                    print("Create the udp client socket success")
                    model.remote.type = .udp_client
                    model.local.type = .udp_server
                    return
                }
            } catch {
                print("Error Connect is \(error);\n")
            }
        }
    }
    
    func loop(_ model: Model) {
        user_input_type_prompt()
        loop: while true {
            do {
                let type = user_input_type()
                type_switch: switch type {
                case .read(let r_type):
                    print("Receiving the data ... ...")
                    var datas: [UInt8]
                    switch model.local.type {
                    case .tcp_client, .tcp_server:
                        datas = try model.remote.recv(byte_length: 2048)
                    case .udp_server:
                        let infos = try model.local.recvfrom(byte_length: 2048)
                        datas = infos.0
                        model.remote.address = infos.1
                        model.remote.port = infos.2
                    case .udp_client:
                        print("The udp client can't read data.")
                        continue
                    }
                    
                    if datas.count == 0 {
                        print("The remote socket is lose.")
                        close()
                        return
                    }
                    
                    var text = ""
                    read_switch: switch r_type {
                    case .int_10:
                        text = "["
                        for data in datas {
                            text += "\(data),"
                        }
                        text += "]"
                    case .int_16:
                        text = "["
                        for data in datas {
                            text += String(format: "0x%x,", data)
                        }
                        text += "]"
                    case .string:
                        if let t = String(data: Data(bytes: datas), encoding: String.Encoding.ascii) {
                            text = t
                        }
                        else {
                            text = String(cString: datas)
                        }
                    }
                    print("From client (\(model.remote.address):\(model.remote.port)) data \(datas.count) bytes : ")
                    print("-----------------------------------------------------")
                    print(text)
                    print("-----------------------------------------------------\n")
                case .send(let s_type):
                    send_switch: switch s_type {
                    case .data(let sd_type):
                        let data = user_input_data(sd_type)
                        if data.count == 0 {
                            print("Can't Send 0 bytes.\n")
                            continue
                        }
                        print("Send data \(data.count) bytes to (\(model.remote.address):\(model.remote.port)).")
                        switch model.local.type {
                        case .tcp_client, .tcp_server:
                            try model.remote.send(byte: data)
                        case .udp_client, .udp_server:
                            try model.local.sendto(
                                byte: data,
                                address: model.remote.address,
                                port: model.remote.port
                            )
                        }
                        print("Send success.\n")
                    case .address(let sa_type):
                        let infos = user_address_port()
                        let data = user_input_data(sa_type)
                        model.remote.address = infos.0
                        model.remote.port = infos.1
                        if data.count == 0 {
                            print("Can't Send 0 bytes.\n")
                            continue
                        }
                        print("Send data \(data.count) bytes to (\(model.remote.address):\(model.remote.port)).")
                        try model.local.sendto(
                            byte: data,
                            address: infos.0,
                            port: infos.1
                        )
                        print("Send success.\n")
                    }
                case .close(let c_type):
                    switch c_type {
                    case .socket:
                        close()
                        return
                    case .app:
                        print("Close the socket.")
                        let _ = try? model.remote.send(text: "EOF!")
                        let _ = try? model.remote.close()
                        let _ = try? model.local.close()
                        print("Exit app.")
                        exit(0)
                    }
                }
            } catch {
                print("Error Loop, error : \(error);")
            }
        }
    }
    
    func close() {
        print("Close the socket.")
        let _ = try? model.remote.send(text: "EOF!")
        let _ = try? model.remote.close()
        let _ = try? model.local.close()
        print("Socket close!\n\n")
    }
    
}

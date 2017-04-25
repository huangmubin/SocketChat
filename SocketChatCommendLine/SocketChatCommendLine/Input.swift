//
//  Input.swift
//  SocketChatCommendLine
//
//  Created by 黄穆斌 on 2017/4/24.
//  Copyright © 2017年 myron. All rights reserved.
//

import Foundation

/*
 0. 选择 Socket 类型
 1. 输入地址跟端口信息
 2. 选择模式
    2.1 读取
    2.2 发送
    2.3 关闭
 */

// MARK: - Socket Info

enum SocketInfo {
    case tcp_server
    case tcp_client
    case udp_server
    case udp_client
}

func user_socket_info() -> SocketInfo {
    var socket: SocketInfo?
    while socket == nil {
        print("The Socket type is")
        print("    tcp_server: tcp server / ts")
        print("    tcp_client: tcp client / tc")
        print("    udp_server: udp server / us")
        print("    udp_client: udp client / uc")
        print("Please input :")
        if let input = String(data: FileHandle.standardInput.availableData, encoding: String.Encoding.ascii) {
            switch input {
            case "tcp server\n", "ts\n":
                socket = SocketInfo.tcp_server
            case "tcp client\n", "tc\n":
                socket = SocketInfo.tcp_client
            case "udp server\n", "us\n":
                socket = SocketInfo.udp_server
            case "udp client\n", "uc\n":
                socket = SocketInfo.udp_client
            default:
                break
            }
        }
    }
    return socket!
}

// MARK: - Socket address info

func user_address_info(type: SocketInfo, model: Model) {
    switch type {
    case .tcp_server:
        user_tcp_server(model)
    case .tcp_client:
        user_tcp_client(model)
    case .udp_server:
        user_udp_server(model)
    case .udp_client:
        user_udp_client(model)
    }
}

private func user_tcp_server(_ model: Model) {
    print("Please input the tcp server's info.")
    let port: Int32 = user_port()
    model.local.address = Socket.host()
    model.local.port    = port
}

private func user_tcp_client(_ model: Model) {
    print("Please input the tcp client connect's server info.")
    let infos = user_address_port()
    model.local.address = Socket.host()
    model.local.port = 0
    model.remote.address = infos.0
    model.remote.port = infos.1
}

private func user_udp_server(_ model: Model) {
    print("Please input the udp server's info.")
    let port: Int32 = user_port()
    model.local.address = Socket.host()
    model.local.port = port
    print("Please input the default remote address'info. (255.255.255.255:xxxx)")
    let infos = user_address_port()
    model.remote.address = infos.0
    model.remote.port = infos.1
}

private func user_udp_client(_ model: Model) {
    print("Please input the udp client's default remote address'info. (255.255.255.255:xxxx).")
    let infos = user_address_port()
    model.remote.address = infos.0
    model.remote.port = infos.1
    
    model.local.address = Socket.host()
    model.local.port = 0
}

// MARK: - Input Address and Port

func user_address_port() -> (String, Int32) {
    var address: String?
    var port: Int32 = 0
    while address == nil {
        print("Please input the address and port (xxx.xxx.xxx.xxx:xxx) :")
        if var input = String(data: FileHandle.standardInput.availableData, encoding: String.Encoding.ascii) {
            input.remove(at: input.index(before: input.endIndex))
            if input.match(pattern: "^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}:[0-9]{1,5}$") {
                let infos = input.characters.split(whereSeparator: { $0 == ":" })
                port = Int32(input.substring(from: infos[1].startIndex))!
                if port < 65535 {
                    address = input.substring(to: infos[0].endIndex)
                }
                else {
                    print("Port is error.")
                }
            }
        }
    }
    return (address!, port)
}

func user_port() -> Int32 {
    var port: Int32?
    while port == nil {
        print("Please input the port 0 ~ 65535 :")
        if var input = String(data: FileHandle.standardInput.availableData, encoding: String.Encoding.ascii) {
            input.remove(at: input.index(before: input.endIndex))
            if let p = Int32(input) {
                if p < 65535 {
                    port = p
                }
            }
        }
    }
    return port!
}

// MARK: - Input Model : Type

enum DataType {
    case int_10
    case int_16
    case oneline
    case block
}

enum SendType {
    case data(DataType)
    case address(DataType)
}

enum ReadType {
    case int_10
    case int_16
    case string
}

enum CloseType {
    case socket
    case app
}

enum InputType {
    case read(ReadType)
    case send(SendType)
    case close(CloseType)
}

func user_input_type_prompt() {
    print("The order type is")
    print("    Read data")
    print("        read text             : r")
    print("        read decimal data     : r10")
    print("        read hexadecimal data : r16")
    print("    Send data")
    print("        send data in line     : s")
    print("        send data in block    : sb")
    print("        send decimal data     : s10")
    print("        send hexadecimal data : s16")
    print("    Send Address and data (Just udp)")
    print("        send data in line     : as")
    print("        send data in block    : as")
    print("        send decimal data     : as10")
    print("        send hexadecimal data : as16")
    print("    Close")
    print("        close socket          : c")
    print("        close socket          : exit")
}

func user_input_type() -> InputType  {
    var type: InputType?
    while type == nil {
        print("Please input order type (help):")
        if let input = String(data: FileHandle.standardInput.availableData, encoding: String.Encoding.ascii) {
            switch input {
            case "help\n":
                user_input_type_prompt()
            case "r\n":
                type = InputType.read(.string)
            case "r10\n":
                type = InputType.read(.int_10)
            case "r16\n":
                type = InputType.read(.int_16)
            case "s\n":
                type = InputType.send(.data(.oneline))
            case "sb\n":
                type = InputType.send(.data(.block))
            case "s10\n":
                type = InputType.send(.data(.int_10))
            case "s16\n":
                type = InputType.send(.data(.int_16))
            case "as\n":
                type = InputType.send(.address(.oneline))
            case "asb\n":
                type = InputType.send(.address(.block))
            case "as10\n":
                type = InputType.send(.address(.int_10))
            case "as16\n":
                type = InputType.send(.address(.int_16))
            case "c\n":
                type = InputType.close(.socket)
            case "exit\n":
                type = InputType.close(.app)
            default:
                break
            }
        }
    }
    return type!
}

// MARK: - Input Model : Data

func user_input_data(_ type: DataType) -> [UInt8] {
    var data: [UInt8]?
    switch type {
    case .oneline:
        print("Please input data :")
        if var input = String(data: FileHandle.standardInput.availableData, encoding: String.Encoding.ascii) {
            input.remove(at: input.index(before: input.endIndex))
            data = input.utf8.map({ return $0 })
        }
    case .block:
        print("Please input data end in \"end!!!\" :")
        print("start!!!")
        var inputs = ""
        var last = ""
        input_loop: while true {
            inputs += last
            if let c_input = String(data: FileHandle.standardInput.availableData, encoding: String.Encoding.ascii) {
                if c_input == "end!!!\n" {
                    break input_loop
                }
                else {
                    last = c_input
                }
            }
        }
        if inputs.characters.count > 0 {
            inputs.remove(at: inputs.index(before: inputs.endIndex))
        }
        data = inputs.utf8.map({ return $0 })
    case .int_10:
        print("Please input [int_10, int_10...] end in \"]\" : ")
        print("[")
        var inputs = [UInt8]()
        input_loop: while true {
            if var c_input = String(data: FileHandle.standardInput.availableData, encoding: String.Encoding.ascii) {
                if c_input == "]\n" {
                    break input_loop
                }
                c_input.remove(at: c_input.index(before: c_input.endIndex))
                if c_input.match(pattern: "^(\\d{1,3},?)+$") {
                    let i_array = c_input.components(separatedBy: ",")
                    for i_text in i_array {
                        if let i = UInt8(i_text) {
                            inputs.append(i)
                        }
                        else {
                            print("\(i_text) is not a UInt8")
                        }
                    }
                }
            }
        }
        data = inputs
    case .int_16:
        print("Please input [int_16, int_16...] end in \"]\" : ")
        print("[")
        var inputs = [UInt8]()
        input_loop: while true {
            if var c_input = String(data: FileHandle.standardInput.availableData, encoding: String.Encoding.ascii) {
                if c_input == "]\n" {
                    break input_loop
                }
                c_input.remove(at: c_input.index(before: c_input.endIndex))
                if c_input.match(pattern: "^([\\d,a-f]{1,2},?)+$") {
                    let i_array = c_input.components(separatedBy: ",")
                    for i_text in i_array {
                        if let i = UInt8(i_text, radix: 16) {
                            inputs.append(i)
                        }
                        else {
                            print("\(i_text) is not a UInt8")
                        }
                    }
                }
                else {
                    print("The \(c_input) is a unvalid input.")
                }
            }
        }
        data = inputs
    }
    return data!
}

// MARK: - Input

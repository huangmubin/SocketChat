//
//  AppData.swift
//  SocketChat
//
//  Created by 黄穆斌 on 2017/4/22.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let SocketUpdate = Notification.Name.init("SocketUpdate")
    static let SocketConnect = Notification.Name.init("SocketConnect")
}

// MARK: - App Data

class AppData: NotifierProtocol {
    
    // 
    static let shared = AppData()
    
    private init() {
        read()
    }
    
    /** 持久化保存数据 */
    func save() {
        var values: [[Any]] = []
        for data in datas {
            values.append([
                data.type.rawValue,
                data.local.address,
                data.local.port,
                data.remote.address,
                data.remote.port
            ])
        }
        UserDefaults.standard.set(values, forKey: "app_datas")
    }
    
    /** 获取本地保存的数据 */
    func read() {
        if let values = UserDefaults.standard.object(forKey: "app_datas") as? [[Any]] {
            for value in values {
                let model = SocketModel()
                model.type = SocketModel.SocketType(rawValue: value[0] as! Int)!
                model.local.address = value[1] as! String
                model.local.port = value[2] as! Int32
                model.remote.address = value[3] as! String
                model.remote.port = value[4] as! Int32
                datas.append(model)
            }
        }
    }
    
    // MARK: - Post
    
    /**  发送更新通知 */
    func post(flag: Int) {
        self.post(name: .SocketUpdate, infos: ["flag": flag], inQueue: DispatchQueue.main)
    }
    
    /** 发送连接更新 */
    func post(connect flag: Int) {
        self.post(name: .SocketConnect, infos: ["flag": flag], inQueue: DispatchQueue.main)
    }
    
    // MARK: - Values
    
    /// Socket 数据列表
    var datas: [SocketModel] = []
    /// 当前正在访问的 Socket 对象
    var current: SocketModel!
    
    // MARK: - Connect Action
    
    /** 根据数据类型进行网络连接 */
    func connect() {
        switch current.type {
        case .server:
            server_connect()
        case .client:
            client_connect()
        case .udp:
            udp_connect()
        }
    }
    
    private func server_connect() {
        DispatchQueue.global().async {
            let model = self.current!
            do {
                print("Try to bind the TCP Server.")
                model.append(event: "Try to bind the TCP Server.")
                self.post(flag: model.flag)
                try model.local.tcp_server(port: model.local.port)
                self.post(connect: model.flag)
                
                print("Try to accept the TCP Client.")
                model.append(event: "Try to accept the TCP Client.")
                self.post(flag: model.flag)
                model.remote = try model.local.accept(time: 0)
                self.post(connect: model.flag)
                
                print("Accept the client Success.")
                model.append(event: "Accept the client Success.")
                self.post(flag: model.flag)
                
                self.read_loop(model)
            } catch {
                let _ = try? model.local.close()
                let _ = try? model.remote.close()
                model.local.socket = nil
                model.remote.socket = nil

                print("Error in TCP Server Socket :  \(error)")
                model.append(event: "Error in Socket :  \(error)")
                self.post(flag: model.flag)
            }
        }
    }
    
    private func client_connect() {
        DispatchQueue.global().async {
            let model = self.current!
            do {
                print("Try to connect the TCP Server.")
                model.append(event: "Try to connect the TCP Server.")
                self.post(flag: model.flag)
                try model.remote.tcp_client(
                    port: model.remote.port,
                    address: model.remote.address
                )
                self.post(connect: model.flag)
                
                model.append(event: "Connect the Server Success.")
                self.post(flag: model.flag)
                
                self.read_loop(model)
            } catch {
                print("Error in TCP Client Socket :  \(error)")
                model.append(event: "Error in Socket :  \(error)")
                self.post(flag: model.flag)
            }
        }
    }
    
    private func udp_connect() {
        DispatchQueue.global().async {
            let model = self.current!
            do {
                print("Try to bind the UDP Server.")
                model.append(event: "Try to bind the UDP Server.")
                self.post(flag: model.flag)
                print("port = \(model.local.port)")
                try model.local.udp_server(port: model.local.port)
                try model.local.broadcast(isOpen: true)
                model.remote.address = "255.255.255.255"
                model.remote.port = model.local.port
                self.post(connect: model.flag)
                
                print("Bind the UDP Server Success.")
                model.append(event: "Bind the UDP Server Success.")
                self.post(flag: model.flag)
                
                self.read_loop(model)
            } catch {
                print("Error in UDP Socket :  \(error)")
                model.append(event: "Error in Socket :  \(error)")
                self.post(flag: model.flag)
            }
        }
    }
    
    // MARK: Read Loop
    
    /** 循环对 Socket 进行数据读取 */
    func read_loop(_ socketModel: SocketModel) {
        DispatchQueue.global().async {
            let model = socketModel
            while true {
                do {
                    switch model.type {
                    case .server:
                        if model.remote.socket == nil || model.local.socket == nil {
                            print("Error in read loop: TCP Server \(model.flag) is nil")
                            return
                        }
                        
                        let data = try model.remote.recv(byte_length: 1024)
                        if data.count == 0 {
                            print("Error in TCP Server remote is close.")
                            model.append(event: "Error in TCP Server remote is close.")
                            self.post(flag: model.flag)
                        }
                        else {
                            model.append(remote_event: data)
                            self.post(flag: model.flag)
                        }
                    case .client:
                        if model.remote.socket == nil {
                            print("Error in read loop: TCP Client \(model.flag) is nil")
                            return
                        }
                        
                        let data = try model.remote.recv(byte_length: 1024)
                        //[69, 79, 70, 33] EOF!
                        if data.elementsEqual([69, 79, 70, 33]) {
                            model.append(event: "TCP Server is close the connect.")
                            self.post(flag: model.flag)
                        }
                        else {
                            model.append(remote_event: data)
                            self.post(flag: model.flag)
                        }
                    case .udp:
                        if model.local.socket == nil {
                            print("Error in read loop: UDP Server \(model.flag) is nil")
                            return
                        }
                        //print("recvfrom start")
                        let infos = try model.local.recvfrom(byte_length: 1024)
                        if infos.1 != model.local.address {
                            model.append(
                                remote_event: infos.0,
                                address: infos.1,
                                port: infos.2
                            )
                            self.post(flag: model.flag)
                        }
                        //print("recvfrom end \(infos.1)")
                    }
                } catch {
                    // TODO: Error
                    print("Error in read loop - flag: \(model.flag); type: \(model.type.hashValue); error: \(error); \(error.localizedDescription)")
                    model.append(event: "Error in socket read loop.")
                    self.post(flag: model.flag)
                    
                    let _ = try? model.local.close()
                    let _ = try? model.remote.close()
                    model.local.socket = nil
                    model.remote.socket = nil
                }
            }
        }
    }
    
    // MARK: - Close
    
    /** 关闭 Socket 连接 */
    func close () {
        let model = self.current!
        if model.type == .server {
            let _ = try? model.remote.send(byte: [69, 79, 70, 33])
        }
        
        let _ = try? model.local.close()
        let _ = try? model.remote.close()
        model.local.socket = nil
        model.remote.socket = nil
        
        model.append(event: "Socket is close.")
        self.post(flag: model.flag)
        self.post(connect: model.flag)
    }
    
    // MARK: - Send
    
    /** 发送数据 */
    func send(bytes: [UInt8]) {
        DispatchQueue.global().async {
            let model = self.current!
            do {
                switch model.type {
                case .server, .client:
                    try model.remote.send(byte: bytes)
                    model.append(local_event: bytes)
                case .udp:
                    try model.local.sendto(
                        byte: bytes,
                        address: model.remote.address,
                        port: model.remote.port
                    )
                    model.append(local_event: bytes, port: model.remote.port)
                }
            } catch {
                //[69, 114, 114, 111, 114, 58, 32]
                model.append(local_event: [69, 114, 114, 111, 114, 58, 32] + bytes)
            }
            self.post(flag: model.flag)
        }
    }
    
    /** 发送数据 */
    func send(text: String) {
        send(bytes: text.utf8.map({ return $0 }))
    }
}

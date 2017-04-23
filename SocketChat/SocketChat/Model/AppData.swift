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
}

class AppData: NotifierProtocol {
    
    // MARK: - Singleton
    
    static let shared = AppData()
    
    init() {
        read()
    }
    
    func save() {
        var values: [[Any]] = []
        for data in datas {
            values.append([
                data.type.toInt(),
                data.address,
                data.port,
                data.remote?.address ?? "",
                data.remote?.port ?? 0
            ])
        }
        UserDefaults.standard.set(values, forKey: "app_datas")
    }
    
    func read() {
        if let values = UserDefaults.standard.object(forKey: "app_datas") as? [[Any]] {
            for value in values {
                let model = SocketModel()
                model.type = Socket.SocketType(rawValue: value[0] as! Int)!
                model.address = value[1] as! String
                model.port = value[2] as! Int32
                model.remote = Socket()
                model.remote!.address = value[3] as! String
                model.remote!.port = value[4] as! Int32
                datas.append(model)
            }
        }
    }
    
    func post() {
        self.post(name: .SocketUpdate, infos: nil, inQueue: DispatchQueue.main)
    }
    
    // MARK: - Values
    
    var datas: [SocketModel] = [SocketModel]()
    
    var current: SocketModel!
    
    // MARK: - Connect Actions
    
    func connect() {
        switch current.type {
        case .tcp_server:
            tcp_server_connect()
        case .tcp_client:
            tcp_client_connect()
        case .udp_server:
            udp_server_connect()
        case .udp_client:
            udp_client_connect()
        }
    }
    
    func tcp_server_connect() {
        DispatchQueue.global().async {
            let socket = self.current!
            let bind_event = EventModel()
            bind_event.address = socket.address
            bind_event.port = socket.port
            do {
                //print("Try to bind the TCP Server.")
                bind_event.note = "Try to bind the TCP Server."
                socket.events.append(bind_event)
                self.post()
                try socket.tcp_server(port: socket.port)
                
                socket.isConnecting = true
                
                let accept_event = bind_event.copy()
                accept_event.note = "Try to accept the TCP Client."
                //print("Try to accept the TCP Client.")
                socket.events.append(accept_event)
                self.post()
                socket.remote = try socket.accept(time: 0)
                
                let success_event = bind_event.copy()
                success_event.note = "Accept the client Success."
                socket.events.append(success_event)
                
                socket.isConnecting = false
                
                self.post()
                
                self.read_loop(socket: socket)
            } catch {
                let _ = try? socket.close()
                socket.socket = nil
                socket.isConnecting = false
                
                let error_event = bind_event.copy()
                error_event.note = "Error in Socket :  \(error)"
                //print("Error in Socket :  \(error)")
                socket.events.append(error_event)
                self.post()
            }
        }
    }
    
    func tcp_client_connect() {
        DispatchQueue.global().async {
            let socket = self.current!
            let connect_event = EventModel()
            connect_event.address = socket.address
            connect_event.port = socket.port
            do {
                connect_event.note = "Try to connect the TCP Server."
                socket.events.append(connect_event)
                self.post()
                try socket.tcp_client(port: socket.port, address: socket.address)
                
                let success_event = connect_event.copy()
                success_event.note = "Connect the Server Success."
                socket.events.append(success_event)
                self.post()
                
                self.read_loop(socket: socket)
            } catch {
                let error_event = connect_event.copy()
                error_event.note = "Error in Socket : \(error)"
                socket.events.append(error_event)
                self.post()
            }
        }
    }
    
    func udp_server_connect() {
        DispatchQueue.global().async {
            let socket = self.current!
            let bind_event = EventModel()
            bind_event.address = socket.address
            bind_event.port = socket.port
            do {
                bind_event.note = "Try to bind the UDP Server."
                socket.events.append(bind_event)
                self.post()
                try socket.udp_server(port: socket.port)
                
                let success_event = bind_event.copy()
                success_event.note = "Bind the client Success."
                socket.events.append(success_event)
                self.post()
                
                self.read_loop(socket: socket)
            } catch {
                let error_event = bind_event.copy()
                error_event.note = "Error in Socket :  \(error)"
                socket.events.append(error_event)
                self.post()
            }
        }
    }

    func udp_client_connect() {
        DispatchQueue.global().async {
            let socket = self.current!
            let create_event = EventModel()
            create_event.address = socket.address
            create_event.port = socket.port
            do {
                create_event.note = "Try to create the UDP Client."
                socket.events.append(create_event)
                self.post()
                try socket.udp_client()
                
                let success_event = create_event.copy()
                success_event.note = "Connect the Server Success."
                socket.events.append(success_event)
                
                try socket.broadcast(isOpen: true)
                let opt_event = create_event.copy()
                opt_event.note = "Open the broadcat Success."
                socket.events.append(opt_event)
                
                self.post()
            } catch {
                let error_event = create_event.copy()
                error_event.note = "Error in Socket : \(error)"
                socket.events.append(error_event)
                self.post()
            }
        }
    }

    // MARK: - Close Action
    
    func close() {
        let socket = self.current!
        let close_event = EventModel()
        close_event.address = socket.address
        close_event.port = socket.port
        
        do {
            try socket.remote?.send(text: "EOF!")
        } catch {
            // print("Error : (\(socket.id)) is send EOF! error.")
        }
        
        do {
            close_event.note = "Try to close the socket."
            socket.events.append(close_event)
            try socket.shutdown(.read_write)
            try socket.close()
        } catch {
            let error_event = close_event.copy()
            error_event.note = "Error in Socket : \(error)"
            socket.events.append(error_event)
        }
        
        socket.socket = nil
        socket.isConnecting = false
        self.post()
    }
    
    // MARK: - Read Loop
    
    func read_loop(socket: SocketModel) {
        DispatchQueue.global().async {
            while true {
                if socket.socket == nil {
                    return
                }
                let event = socket.event()
                event.from = .remote
                do {
                    switch socket.type {
                    case .tcp_server:
                        if let remote = socket.remote {
                            let data = try remote.recv(byte_length: 1024)
                            if data.count > 0 {
                                event.address = remote.address
                                event.port = remote.port
                                event.data = data
                                event.note = String(cString: data)
                            }
                            else {
                                event.note = "Error in socket and close."
                                event.from = .system
                                let _ = try? socket.remote?.close()
                                let _ = try? socket.close()
                                socket.remote = nil
                                socket.socket = nil
                            }
                            socket.events.append(event)
                            self.post()
                        }
                    case .tcp_client:
                        let data = try socket.recv(byte_length: 1024)
                        event.data = data
                        event.note = String(cString: data)
                        socket.events.append(event)
                        //print(event.note)
                        self.post()
                    case .udp_server:
                        let infos = try socket.recvfrom(byte_length: 1024)
                        event.data = infos.0
                        event.note = String(cString: infos.0)
                        socket.remote?.address = infos.1
                        socket.remote?.port = infos.2
                        socket.events.append(event)
                        self.post()
                    case .udp_client:
                        break
                    }
                } catch {
                    // print("Error: -(\(socket.id)) \(error.localizedDescription); \(error)")
                    if "\(error)" == "read" {
                        let _ = try? socket.close()
                        event.note = "Error in socket and close."
                        event.from = .system
                        socket.events.append(event)
                        socket.socket = nil
                        return
                    }
                }
                
                print("Read : (\(socket.id)) read \(String(describing: socket.events.last?.note)); \(String(describing: socket.events.last?.data))")
                
                if event.data == [69, 79, 70, 33] {
                    let _ = try? socket.close()
                    socket.socket = nil
                }
                Thread.sleep(forTimeInterval: 0.1)
            }
        }
    }
    
    // MARK: - Send
    
    func send(text: String) {
        DispatchQueue.global().async {
            let socket = self.current!
            let event = socket.event()
            event.from = .local
            
            do {
                switch socket.type {
                case .tcp_server:
                    try socket.remote?.send(text: text)
                case .tcp_client:
                    try socket.send(text: text)
                case .udp_server, .udp_client:
                    try socket.sendto(
                        text: text,
                        address: socket.remote?.address,
                        port: socket.remote?.port,
                        time: 0
                    )
                }
                event.note = text
            } catch {
                event.note = "Error in Send: \(text)"
            }
            
            socket.events.append(event)
            self.post()
        }
    }
    
    func send(bytes: [UInt8]) {
        DispatchQueue.global().async {
            let socket = self.current!
            let event = socket.event()
            event.from = .local
            
            do {
                switch socket.type {
                case .tcp_server:
                    try socket.remote?.send(byte: bytes)
                case .tcp_client:
                    try socket.send(byte: bytes)
                case .udp_server, .udp_client:
                    try socket.sendto(
                        byte: bytes,
                        address: socket.remote?.address,
                        port: socket.remote?.port,
                        time: 0
                    )
                }
                event.isNote = false
                event.data = bytes
            } catch {
                event.isNote = true
                event.note = "Error in Send: \(bytes)"
            }
            
            socket.events.append(event)
            self.post()
        }
    }
}

//
//  AppData.swift
//  SocketChat
//
//  Created by 黄穆斌 on 2017/4/22.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

class AppData {
    
    // MARK: - Singleton
    
    static let shared = AppData()
    
    init() {
        
    }
    
    // MARK: - Values
    
    var datas: [SocketModel] = {
        var sockets = [SocketModel]()
        
        let _ = {
            let unit = SocketModel()
            unit.type = Socket.SocketType.tcp_server
            unit.id = unit.type.toString()
            unit.address = Socket.host()
            unit.port = 1234
            sockets.append(unit)
        }()
        
        let _ = {
            let unit = SocketModel()
            unit.type = Socket.SocketType.tcp_client
            unit.id = unit.type.toString()
            unit.address = "127.0.0.1"
            unit.port = 1234
            sockets.append(unit)
        }()
        
        let _ = {
            let unit = SocketModel()
            unit.type = Socket.SocketType.udp_server
            unit.id = unit.type.toString()
            unit.address = "0.0.0.0"
            unit.port = 5678
            sockets.append(unit)
        }()
        
        let _ = {
            let unit = SocketModel()
            unit.type = Socket.SocketType.udp_client
            unit.id = unit.type.toString()
            unit.address = "255.255.255.255"
            unit.port = 5678
            sockets.append(unit)
        }()
        
        return sockets
    }()
    
    var current: SocketModel!
}

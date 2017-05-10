//
//  SocketData.swift
//  SocketChat
//
//  Created by Myron on 2017/4/22.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

extension SocketModel {
    
    enum SocketType: Int {
        case server = 0
        case client = 1
        case udp    = 2
    }
    
}

// MARK: - Socket Model
/**
 Socket 数据模型。
 */
class SocketModel {
    
    // MARK: Data
    
    /// Socket 标记
    var flag: Int = 0
    /// 事件列表
    var events: [EventModel] = [EventModel()]
    /// 类型
    var type: SocketModel.SocketType = .udp
    /// 本地端口用于记录本地信息
    var local: Socket = Socket()
    /// 远程端口 tcp server 中用于通讯的实际端口
    var remote: Socket = Socket()
    
    // MARK: Action
    
    /// 添加 System 事件内容
    func append(event: String) {
        DispatchQueue.main.async {
            self.events.append(
                EventModel(note: event)
            )
        }
    }
    
    /// 添加 Remote 事件内容
    func append(remote_event data: [UInt8], address: String? = nil, port: Int32? = nil) {
        for event in events.reversed() {
            if event.from == .remote {
                if address != nil && port != nil {
                    if address! != event.address || port! != event.port {
                        break
                    }
                }
                if event.data.elementsEqual(data) {
                    event.times += 1
                    return
                }
                break
            }
        }
        
        let event = EventModel()
        event.data = data
        event.address = address ?? remote.address
        event.port = port ?? remote.port
        event.from = .remote
        event.type = .i_16
        events.append(event)
    }
    
    /// 添加 Local 事件内容
    func append(local_event data: [UInt8], address: String? = nil, port: Int32? = nil) {
        for event in events.reversed() {
            if event.from == .local {
                if address != nil && port != nil {
                    if address! != event.address || port! != event.port {
                        break
                    }
                }
                if event.data.elementsEqual(data) {
                    event.times += 1
                    return
                }
                break
            }
        }
        
        let event = EventModel()
        event.data = data
        event.address = address ?? remote.address
        event.port = port ?? remote.port
        event.from = .local
        event.type = .i_16
        events.append(event)
    }
    
    // MARK: Init
    
    static var total_flag: Int = 0
    init() {
        SocketModel.total_flag += 1
        flag = SocketModel.total_flag
    }
    
}

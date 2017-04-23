//
//  EventData.swift
//  SocketChat
//
//  Created by Myron on 2017/4/22.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

extension EventModel {
    
    enum DataSource {
        case system
        case local
        case remote
    }
    
}

class EventModel {
    
    var isNote: Bool = true
    var data: [UInt8] = []
    var note: String = ""
    func changed() {
        if isNote {
            data = note.utf8.map({ return $0 })
        }
        else {
            note = String(cString: data)
        }
    }
    
    var from: DataSource = DataSource.system
    var address: String = ""
    var port: Int32 = 0
    
    func message_ip() -> String {
        switch from {
        case .system:
            return ""
        default:
            return "\(address) : \(port)"
        }
    }
    
    func message_note() -> String {
        if isNote {
            return note
        }
        else {
            var s = ""
            for d in data {
                s += "\(d),"
            }
            if s.characters.count > 1 {
                s.remove(at: s.index(before: s.endIndex))
            }
            return "[\(s)]"
        }
    }
    
    // MARK: - Init
    
    init() {
        note = "Create Socket"
    }
    
    func copy() -> EventModel {
        let new = EventModel()
        new.address = address
        new.port = port
        return new
    }
    
}

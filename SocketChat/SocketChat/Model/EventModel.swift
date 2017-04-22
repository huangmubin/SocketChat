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
    
    func toString() -> String {
        switch from {
        case .system:
            return note
        default:
            var s = ""
            for d in data {
                s += "\(d),"
            }
            return "\(address):\(port)\n[\(s)]"
        }
    }
    
    // MARK: - Init
    
    init() {
        note = "Create Socket"
    }
    
    
}
//
//  EventData.swift
//  SocketChat
//
//  Created by Myron on 2017/4/22.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

// MARK: - Event Model Data Source

extension EventModel {
    
    enum DataSource {
        case system
        case local
        case remote
    }
    
    /**
     文本、十六进制、十进制
     */
    enum ShowType {
        case note
        case i_16
        case i_10
    }
    
}

// MARK: - Event Model

class EventModel {
    
    ///  事件数据
    var data: [UInt8] = []
    /// 数据的显示类型
    var type: EventModel.ShowType = .note
    ///  数据来源
    var from: EventModel.DataSource = .system
    /// 数据重复次数
    var times: Int = 1
    /// 设置数据
    var note: String {
        set { data = newValue.utf8.map({ return $0 }) }
        get {
            switch type {
            case .note:
                var text = String(cString: data)
                if text.characters.count == data.count {
                    return text
                }
                else {
                    return text[0 ..< data.count]
                }
            case .i_16:
                var text = ""
                for i in data {
                    let note = String(format: "%x", i)
                    if note.characters.count == 2 {
                        text += "0x\(note)  "
                    }
                    else {
                        text += "0x0\(note)  "
                    }
                }
                return text
            case .i_10:
                var text = ""
                for i in data {
                    let note = String(format: "%d", i)
                    if note.characters.count == 2 {
                        text += "0\(note)  "
                    }
                    else if note.characters.count == 1 {
                        text += "00\(note)  "
                    }
                    else {
                        text += "\(note)  "
                    }
                }
                return text
            }
        }
    }
    
    ///  格式化数据
    var toString: String {
        switch type {
        case .note:
            return note
        case .i_10:
            var r_note = "["
            for i in data {
                r_note += "\(i), "
            }
            return r_note + "]"
        case .i_16:
            var r_note = "["
            for i in data {
                let x = String(format: "%x", i)
                if x.characters.count == 1 {
                    r_note += "0x0\(x), "
                }
                else {
                    r_note += "0x\(x), "
                }
            }
            return r_note + "]"
        }
    }
    
    // MARK: UDP Remote
    
    var address: String = ""
    var port: Int32 = 0
    
    // MARK: Init
    
    init() {
        note = "Create Socket."
    }
    
    init(note: String) {
        self.note = note
    }
    
}

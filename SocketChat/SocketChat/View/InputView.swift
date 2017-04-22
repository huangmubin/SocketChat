//
//  InputView.swift
//  SocketChat
//
//  Created by Myron on 2017/4/22.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

@objc protocol InputViewDelegate {
    func inputview(connect_action inputview: InputView)
    func inputview(send_action inputview: InputView)
}

class InputView: View {

    weak var delegate: InputViewDelegate?
    
    @IBOutlet weak var buffer_label: UILabel!
    @IBOutlet weak var type_control: UISegmentedControl!
    @IBAction func type_changed(_ sender: UISegmentedControl) {
        func split_text() -> [String]? {
            if let text = message_text.text {
                return text.components(separatedBy: ",")
            }
            return nil
        }
        func update_buffer(bytes: [UInt8]) {
            switch sender.selectedSegmentIndex {
            case 1:
                if bytes.count > 0 {
                    var text = "["
                    for byte in bytes {
                        let s = String(format: "%x", byte)
                        if s.characters.count == 1 {
                            text += "0x0\(s),"
                        }
                        else {
                            text += "0x\(s),"
                        }
                    }
                    buffer_label.text = "\(text)]"
                }
                else {
                    buffer_label.text = "Buffer"
                }
            case 2:
                if bytes.count > 0 {
                    var text = "["
                    for byte in bytes {
                        text += String(format: "%d,", byte)
                    }
                    buffer_label.text = "\(text)]"
                }
                else {
                    buffer_label.text = "Buffer"
                }
            default: break
            }
        }
        
        var bytes = [UInt8]()
        switch sender.selectedSegmentIndex {
        case 0:
            send_button.isEnabled = (message_text.text?.isEmpty == false)
            if message_text.text?.isEmpty == false {
                send_button.isEnabled = true
                buffer_label.text = message_text.text
            }
            else {
                buffer_label.text = "Buffer"
            }
        case 1:
            if let texts = split_text() {
                for text in texts {
                    let number = (text.hasPrefix("0x") || text.hasPrefix("0X")) ? text[2 ..< text.characters.count] : text
                    if let byte = UInt8(number, radix: 16) {
                        bytes.append(byte)
                    }
                }
            }
        case 2:
            if let texts = split_text() {
                var bytes = [UInt8]()
                for text in texts {
                    if let byte = UInt8(text, radix: 10) {
                        bytes.append(byte)
                    }
                }
            }
        default: break
        }
        update_buffer(bytes: bytes)
    }
    
    @IBOutlet weak var send_button: UIButton!
    @IBAction func send_action(_ sender: UIButton) {
        delegate?.inputview(send_action: self)
    }
    
    @IBOutlet weak var message_text: UITextField!
    @IBAction func message_text_changed(_ sender: UITextField) {
        type_changed(type_control)
    }
    
    @IBOutlet weak var connect_button: UIButton!
    @IBAction func connect_action(_ sender: UIButton) {
        delegate?.inputview(connect_action: self)
    }
    
    
    func update_buttons(isCreated: Bool, isConneting: Bool) {
        if !isCreated {
            message_text.isHidden = true
            send_button.isHidden = true
            connect_button.isHidden = false
            connect_button.isEnabled = true
        }
        else if isConneting {
            message_text.isHidden = true
            send_button.isHidden = true
            connect_button.isHidden = false
            connect_button.isEnabled = false
        }
        else {
            message_text.isHidden = false
            send_button.isHidden = false
            connect_button.isHidden = true
            connect_button.isEnabled = true
        }
    }
    
}

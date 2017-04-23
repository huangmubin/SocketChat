//
//  InfoInputView.swift
//  SocketChat
//
//  Created by Myron on 2017/4/22.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

@objc protocol InfoInputViewDelegate {
    func info_inputview(inputview: InfoInputView, send: String)
}

enum InfoInputType {
    case name
    case address
    case port
}

class InfoInputView: View {

    var type: InfoInputType = InfoInputType.name
    
    weak var delegate: InfoInputViewDelegate?
    weak var button: UIButton?
    
    @IBOutlet weak var send_button: UIButton!
    @IBAction func send_action(_ sender: UIButton) {
        button?.setTitle(message_text.text!, for: .normal)
        delegate?.info_inputview(inputview: self, send: message_text.text!)
        message_text.resignFirstResponder()
    }
    
    @IBOutlet weak var cancel_button: UIButton!
    @IBAction func cancel_action(_ sender: UIButton) {
        message_text.resignFirstResponder()
    }
    
    @IBOutlet weak var message_text: UITextField!
    @IBAction func message_text_changed(_ sender: UITextField) {
        switch type {
        case .name:
            send_button.isEnabled = message_text.text?.isEmpty == false
        case .address:
            if let text = message_text.text {
                send_button.isEnabled = text.match(
                    pattern: "^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$"
                )
            }
            else {
                send_button.isEnabled = false
            }
        case .port:
            if let text = message_text.text {
                send_button.isEnabled = Int32(text) != nil
            }
            else {
                send_button.isEnabled = false
            }
        }
    }
    
}

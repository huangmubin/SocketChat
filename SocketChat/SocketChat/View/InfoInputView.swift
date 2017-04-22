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
    
    @IBOutlet weak var send_button: UIButton!
    @IBAction func send_action(_ sender: UIButton) {
        delegate?.info_inputview(inputview: self, send: message_text.text!)
    }
    
    @IBOutlet weak var message_text: UITextField!
    @IBAction func message_text_changed(_ sender: UITextField) {
        
    }
    
}

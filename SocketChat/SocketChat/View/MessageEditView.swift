//
//  MessageEditView.swift
//  SocketChat
//
//  Created by 黄穆斌 on 2017/5/7.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

@objc protocol MessageEditViewDelegate {
    func message_edit_action(_ sender: UIButton)
    func message_send_action(_ sender: UIButton, text: String)
    func message_textview_change(_ textView: UITextView, height: CGFloat)
}

class MessageEditView: UIView, UITextViewDelegate {

    weak var delegate: MessageEditViewDelegate?
    
    @IBOutlet weak var edit_button: UIButton!
    @IBOutlet weak var send_button: UIButton!
    @IBOutlet weak var input_textview: UITextView! {
        didSet {
            input_textview.delegate = self
        }
    }
    
    @IBAction func edit_action(_ sender: UIButton) {
        delegate?.message_edit_action(sender)
        input_textview.resignFirstResponder()
    }
    
    @IBAction func send_action(_ sender: UIButton) {
        delegate?.message_send_action(sender, text: input_textview.text)
        input_textview.text = ""
    }

    func textViewDidChange(_ textView: UITextView) {
        let height = textView.contentSize.height + 17
        if height != textView.bounds.height {
            delegate?.message_textview_change(textView, height: height)
        }
        send_button.isEnabled = !textView.text.isEmpty
    }
}


//@IBOutlet weak var message_edit_button: UIButton!
//@IBOutlet weak var message_send_button: UIButton!
//@IBOutlet weak var message_input_textview: UITextView! {
//    didSet {
//        message_input_textview.delegate = self
//    }
//}
//
//@IBAction func message_edit_action(_ sender: UIButton) {
//    message_input_textview.resignFirstResponder()
//    UIView.animate(withDuration: 0.25, animations: {
//        self.layout_message_bottom.constant = 200
//        self.view.layoutIfNeeded()
//    })
//}
//@IBAction func message_send_action(_ sender: UIButton) {
//    AppData.shared.send(text: message_input_textview.text)
//    message_input_textview.text = ""
//}
//
//func textViewDidChange(_ textView: UITextView) {
//    let height = textView.contentSize.height + 17
//    if height != layout_message_height.constant {
//        UIView.animate(withDuration: 0.25, animations: {
//            self.layout_message_height.constant = height
//            self.view.layoutIfNeeded()
//        })
//    }
//    message_send_button.isEnabled = !message_input_textview.text.isEmpty
//}

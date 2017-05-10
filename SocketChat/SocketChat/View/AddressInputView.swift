//
//  AddressInputView.swift
//  SocketChat
//
//  Created by 黄穆斌 on 2017/5/7.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

@objc protocol AddressInputViewDelegate {
    func address_input_save_action(type: Int, text: String)
}

class AddressInputView: UIView {

    // MARK: - Views
    
    weak var delegate: AddressInputViewDelegate?
    
    @IBOutlet weak var info: UILabel!
    @IBOutlet weak var textfield: UITextField!
    @IBOutlet weak var save: UIButton!
    
    // MARK: - Action
    
    @IBAction func textfield_changed(_ sender: UITextField) {
        if textfield.placeholder == "xxx.xxx.xxx.xxx" {
            var result = false
            if let values = textfield.text?.characters.split(separator: ".") {
                if values.count == 4 {
                    result = true
                    value_loop: for value in values {
                        let text = String(value)
                        if let i = Int(text) {
                            if i < 0 || i > 255 {
                                result = false
                                break value_loop
                            }
                        }
                    }
                }
            }
            // let pattern = "^[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}$"
            save.isEnabled = result
        }
        else {
            if let port = Int(textfield.text ?? "") {
                save.isEnabled = (port > 100 && port < 65535)
            }
            else {
                save.isEnabled = false
            }
        }
    }

    @IBAction func save_action(_ sender: UIButton) {
        delegate?.address_input_save_action(
            type: input_type,
            text: textfield.text!
        )
        textfield.resignFirstResponder()
    }
    
    // MARK: - Update
    
    enum InputType {
        case local_address(String)
        case local_port(Int32)
        case remote_address(String)
        case remote_port(Int32)
    }
    
    var input_type: Int = 0
    
    func update_message_info(_ type: InputType) {
        switch type {
        case .local_address(let address):
            input_type = 0
            info.text = "Local Address"
            textfield.text = address
            textfield.placeholder = "xxx.xxx.xxx.xxx"
            textfield.keyboardType = .decimalPad
        case .local_port(let port):
            input_type = 1
            info.text = "Local Port"
            textfield.text = port.description
            textfield.placeholder = "xxxxx"
            textfield.keyboardType = .numberPad
        case .remote_address(let address):
            input_type = 2
            info.text = "Remote Address"
            textfield.text = address
            textfield.placeholder = "xxx.xxx.xxx.xxx"
            textfield.keyboardType = .decimalPad
        case .remote_port(let port):
            input_type = 3
            info.text = "Remote Port"
            textfield.text = port.description
            textfield.placeholder = "xxxxx"
            textfield.keyboardType = .numberPad
        }
        
        textfield.becomeFirstResponder()
        save.isEnabled = true
    }
    
    /*
    @IBAction func input_save_action(_ sender: UIButton) {
        input_message_textfield.resignFirstResponder()
        UIView.animate(withDuration: 0.25, animations: {
            self.layout_input_top.constant = UIScreen.main.bounds.height
            self.view.layoutIfNeeded()
        })
        
        switch input_info_label.text! {
        case "Local Address":
            model.local.address = input_message_textfield.text!
            //            local_address_button.setTitle(
            //                model.local.address,
            //                for: .normal
        //            )
        case "Local Port":
            model.local.port = Int32(input_message_textfield.text!)!
            //            local_port_button.setTitle(
            //                model.local.port.description,
            //                for: .normal
        //            )
        case "Remote Address":
            model.remote.address = input_message_textfield.text!
            //            remote_address_button.setTitle(
            //                model.remote.address,
            //                for: .normal
        //            )
        case "Remote Port":
            model.remote.port = Int32(input_message_textfield.text!)!
            //            remote_port_button.setTitle(
            //                model.remote.port.description,
            //                for: .normal
        //            )
        default:
            break
        }
    }
    
    enum InputType {
        case local_address
        case local_port
        case remote_address
        case remote_port
    }
    
    func update_message_info(_ type: InputType) {
        switch type {
        case .local_address:
            input_info_label.text = "Local Address"
            input_message_textfield.text = model.local.address
            input_message_textfield.placeholder = "xxx.xxx.xxx.xxx"
            input_message_textfield.keyboardType = .decimalPad
        case .local_port:
            input_info_label.text = "Local Port"
            input_message_textfield.text = model.local.port.description
            input_message_textfield.placeholder = "xxxxx"
            input_message_textfield.keyboardType = .numberPad
        case .remote_address:
            input_info_label.text = "Remote Address"
            input_message_textfield.text = model.remote.address
            input_message_textfield.placeholder = "xxx.xxx.xxx.xxx"
            input_message_textfield.keyboardType = .decimalPad
        case .remote_port:
            input_info_label.text = "Remote Port"
            input_message_textfield.text = model.remote.port.description
            input_message_textfield.placeholder = "xxxxx"
            input_message_textfield.keyboardType = .numberPad
        }
        
        input_message_textfield.becomeFirstResponder()
        input_save_button.isEnabled = true
        
        UIView.animate(withDuration: 0.25, animations: {
            self.layout_input_top.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
*/
}

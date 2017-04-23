//
//  InfoController.swift
//  SocketChat
//
//  Created by 黄穆斌 on 2017/4/22.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

class InfoController: UIViewController, InfoInputViewDelegate, NotifierProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()
        update_info()
        self.observer(name: .UIKeyboardWillChangeFrame, selector: #selector(keyboard_notification(notify:)))
        self.observer(name: .SocketUpdate, selector: #selector(closeNotification(notify:)))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.unobserver()
    }

    func update_info() {
        let data = AppData.shared.current!
        
        name_button.setTitle(data.id, for: .normal)
        type_control.selectedSegmentIndex = data.type.toInt()
        close_button.isEnabled = data.socket != nil
        type_control.isEnabled = !close_button.isEnabled
        
        switch data.type {
        case .tcp_server:
            server_address_button.setTitle(data.address, for: .normal)
            server_port_button.setTitle("\(data.port)", for: .normal)
            client_address_button.setTitle(
                data.remote?.address.isEmpty == false ? data.remote!.address : "Address",
                for: .normal
            )
            client_port_button.setTitle(
                data.remote == nil ? "Port" : (data.remote!.port != 0 ? "\(data.remote!.port)" : "Port"),
                for: .normal
            )
            
            server_address_button.isEnabled = false
            server_port_button.isEnabled    = data.socket == nil
            client_address_button.isEnabled = false
            client_port_button.isEnabled    = false
        case .tcp_client:
            server_address_button.setTitle(data.address, for: .normal)
            server_port_button.setTitle("\(data.port)", for: .normal)
            client_address_button.setTitle("127.0.0.1", for: .normal)
            client_port_button.setTitle("Random", for: .normal)
            
            server_address_button.isEnabled = data.socket == nil
            server_port_button.isEnabled    = data.socket == nil
            client_address_button.isEnabled = false
            client_port_button.isEnabled    = false
        case .udp_server:
            server_address_button.setTitle(data.address, for: .normal)
            server_port_button.setTitle("\(data.port)", for: .normal)
            client_address_button.setTitle(data.remote!.address, for: .normal)
            client_port_button.setTitle("\(data.remote!.port)", for: .normal)
            
            server_address_button.isEnabled = false
            server_port_button.isEnabled    = data.socket == nil
            client_address_button.isEnabled = true
            client_port_button.isEnabled    = true
        case .udp_client:
            server_address_button.setTitle(data.remote!.address, for: .normal)
            server_port_button.setTitle("\(data.remote!.port)", for: .normal)
            client_address_button.setTitle(data.address, for: .normal)
            client_port_button.setTitle("\(data.port)", for: .normal)
            
            server_address_button.isEnabled = true
            server_port_button.isEnabled    = true
            client_address_button.isEnabled = false
            client_port_button.isEnabled    = true
        }
    }
    
    // MARK: - Input View
    
    @IBOutlet weak var inputview: InfoInputView! {
        didSet {
            inputview.delegate = self
        }
    }
    @IBOutlet weak var layout_inputview_bottom: NSLayoutConstraint!
    func info_inputview(inputview: InfoInputView, send: String) {
        if inputview.button === name_button {
            AppData.shared.current.id = send
        }
        else {
            switch AppData.shared.current.type {
            case .tcp_server:
                if inputview.button === server_port_button {
                    AppData.shared.current.port = Int32(send)!
                }
            case .tcp_client:
                if inputview.button === server_address_button {
                    AppData.shared.current.address = send
                }
                else {
                    AppData.shared.current.port = Int32(send)!
                }
            case .udp_server:
                if inputview.button === server_port_button {
                    AppData.shared.current.port = Int32(send)!
                }
                else if inputview.button === client_address_button {
                    AppData.shared.current.remote!.address = send
                }
                else if inputview.button === client_port_button {
                    AppData.shared.current.remote!.port = Int32(send)!
                }
            case .udp_client:
                if inputview.button === server_address_button {
                    AppData.shared.current.remote!.address = send
                }
                else if inputview.button === server_port_button {
                    AppData.shared.current.remote!.port = Int32(send)!
                }
                else if inputview.button === client_port_button {
                    AppData.shared.current.port = Int32(send)!
                }
            }
        }
    }
    
    func push_inputview(type: InfoInputType, sender: UIButton) {
        inputview.type = type
        inputview.message_text.text = sender.title(for: .normal)
        inputview.button = sender
        inputview.message_text.becomeFirstResponder()
    }
    
    func pull_inputview() {
        inputview.message_text.resignFirstResponder()
    }
    
    func keyboard_notification(notify: Notification) {
        if let rect = notify.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            var height = self.view.bounds.height - rect.cgRectValue.origin.y
            if height == -64 {
                height = -inputview.bounds.height
            }
            else {
                height += 64
            }
            UIView.animate(withDuration: 0.25, animations: {
                self.layout_inputview_bottom.constant = height
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // MARK: - Name
    
    @IBOutlet weak var name_button: UIButton!
    @IBAction func name_action(_ sender: UIButton) {
        push_inputview(type: .name, sender: sender)
    }
    
    // MARK: - Control
    
    @IBOutlet weak var type_control: UISegmentedControl!
    @IBAction func type_control_changed(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            AppData.shared.current.type = .tcp_server
            AppData.shared.current.remote = nil
        case 1:
            AppData.shared.current.type = .tcp_client
            AppData.shared.current.remote = nil
        case 2:
            AppData.shared.current.type = .udp_server
            let socket = Socket()
            socket.address = "255.255.255.255"
            socket.port = AppData.shared.current.port
            AppData.shared.current.remote = socket
        case 3:
            AppData.shared.current.type = .udp_client
            let socket = Socket()
            socket.address = "255.255.255.255"
            socket.port = AppData.shared.current.port
            AppData.shared.current.remote = socket
        default: return
        }
        update_info()
    }
    
    // MARK: - Server
    
    @IBOutlet weak var server_address_button: UIButton!
    @IBOutlet weak var server_port_button: UIButton!
    
    @IBAction func server_address_action(_ sender: UIButton) {
        push_inputview(type: .address, sender: sender)
    }
    
    @IBAction func server_port_action(_ sender: UIButton) {
        push_inputview(type: .port, sender: sender)
    }
    
    // MARK: - Client
    
    @IBOutlet weak var client_address_button: UIButton!
    @IBOutlet weak var client_port_button: UIButton!
    
    @IBAction func client_address_action(_ sender: UIButton) {
        push_inputview(type: .address, sender: sender)
    }
    
    @IBAction func client_port_action(_ sender: UIButton) {
        push_inputview(type: .port, sender: sender)
    }
    
    // MARK: - Close
    
    @IBOutlet weak var close_button: UIButton!
    @IBAction func close_action(_ sender: UIButton) {
        AppData.shared.close()
    }
    
    func closeNotification(notify: Notification) {
        self.update_info()
    }
    
}

//
//  SocketInfoView.swift
//  SocketChat
//
//  Created by 黄穆斌 on 2017/5/6.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

@objc protocol SocketInfoViewDelegate {
    func socket_info(changed_type sender: UIButton)
    func socket_info(changed_info sender: UIButton)
    func socket_info(changed_status sender: UIButton)
}

class SocketInfoView: UIView {

    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        deploy()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        deploy()
    }
    
    private func deploy() {
        
    }
    
    // MAKR: - Delegate
    
    weak var delegate: SocketInfoViewDelegate?
    
    @discardableResult
    func update(model: SocketModel) -> Bool {
        // Update title
        update(
            local_addr: model.local.address,
            local_port: model.local.port.description,
            remote_addr: model.remote.address,
            remote_port: model.remote.port.description
        )
        
        // Update Views
        switch model.type {
        case .server:
            update(type_image: 0)
            if model.local.socket == nil {
                update(type_enable: true)
                update(info_enable: 0, is_connected: false)
                update(status_title: "Bind", enable: true)
                return true
            }
            else if model.remote.socket == nil {
                update(type_enable: false)
                update(info_enable: 0, is_connected: true)
                update(status_title: "Accepting", enable: false)
                return true
            }
            else {
                update(type_enable: false)
                update(info_enable: 0, is_connected: true)
                update(status_title: "Close", enable: true)
            }
        case .client:
            update(type_image: 1)
            if model.remote.socket == nil {
                update(type_enable: true)
                update(info_enable: 1, is_connected: false)
                update(status_title: "Connect", enable: true)
                return true
            }
            else {
                update(type_enable: false)
                update(info_enable: 1, is_connected: true)
                update(status_title: "Close", enable: true)
            }
        case .udp:
            update(type_image: 2)
            if model.local.socket == nil {
                update(type_enable: true)
                update(info_enable: 2, is_connected: false)
                update(status_title: "Bind", enable: true)
                return true
            }
            else {
                update(type_enable: false)
                update(info_enable: 2, is_connected: true)
                update(status_title: "Close", enable: true)
            }
        }
        return false
    }
    
    // MARK: - Type Button
    
    @IBOutlet weak var server: UIButton!
    @IBOutlet weak var client: UIButton!
    @IBOutlet weak var udp   : UIButton!
    
    @IBAction func server_action(_ sender: UIButton) {
        delegate?.socket_info(changed_type: sender)
        update(type_image: 0)
        update(info_enable: 0, is_connected: false)
    }
    @IBAction func client_action(_ sender: UIButton) {
        delegate?.socket_info(changed_type: sender)
        update(type_image: 1)
        update(info_enable: 1, is_connected: false)
    }
    @IBAction func udp_action(_ sender: UIButton) {
        delegate?.socket_info(changed_type: sender)
        update(type_image: 2)
        update(info_enable: 2, is_connected: false)
    }
    
    func update(type_image: Int) {
        switch type_image % 3 {
        case 0:
            server.setImage(#imageLiteral(resourceName: "type_server_open"),  for: .normal)
            client.setImage(#imageLiteral(resourceName: "type_client_close"), for: .normal)
            udp   .setImage(#imageLiteral(resourceName: "type_udp_close"),    for: .normal)
        case 1:
            server.setImage(#imageLiteral(resourceName: "type_server_close"),  for: .normal)
            client.setImage(#imageLiteral(resourceName: "type_client_open"), for: .normal)
            udp   .setImage(#imageLiteral(resourceName: "type_udp_close"),    for: .normal)
        default:
            server.setImage(#imageLiteral(resourceName: "type_server_close"),  for: .normal)
            client.setImage(#imageLiteral(resourceName: "type_client_close"), for: .normal)
            udp   .setImage(#imageLiteral(resourceName: "type_udp_open"),    for: .normal)
        }
    }
    
    func update(type_enable enable: Bool) {
        server.isEnabled = enable
        client.isEnabled = enable
        udp   .isEnabled = enable
    }
    
    // MARK: - Address and Port
    
    @IBOutlet weak var local_addr: UIButton!
    @IBOutlet weak var local_port: UIButton!
    @IBOutlet weak var remote_addr: UIButton!
    @IBOutlet weak var remote_port: UIButton!
    
    @IBAction func local_addr_action(_ sender: UIButton) {
        delegate?.socket_info(changed_info: sender)
    }
    @IBAction func local_port_action(_ sender: UIButton) {
        delegate?.socket_info(changed_info: sender)
    }
    @IBAction func remote_addr_action(_ sender: UIButton) {
        delegate?.socket_info(changed_info: sender)
    }
    @IBAction func remote_port_action(_ sender: UIButton) {
        delegate?.socket_info(changed_info: sender)
    }
    
    func update(info_enable: Int, is_connected: Bool) {
        switch info_enable % 3 {
        case 0:
            local_addr.isEnabled = false
            local_port.isEnabled = !is_connected
            remote_addr.isEnabled = false
            remote_port.isEnabled = false
        case 1:
            local_addr.isEnabled = false
            local_port.isEnabled = false
            remote_addr.isEnabled = !is_connected
            remote_port.isEnabled = !is_connected
        default:
            local_addr.isEnabled = false
            local_port.isEnabled = !is_connected
            remote_addr.isEnabled = true
            remote_port.isEnabled = true
        }
    }
    
    func update(local_addr: String, local_port: String, remote_addr: String, remote_port: String) {
        self.local_addr.setTitle(local_addr, for: .normal)
        self.local_port.setTitle(local_port, for: .normal)
        self.remote_addr.setTitle(remote_addr, for: .normal)
        self.remote_port.setTitle(remote_port, for: .normal)
    }
    
    // MARK: - Status Button
    
    @IBOutlet weak var status: UIButton!
    
    @IBAction func status_action(_ sender: UIButton) {
        delegate?.socket_info(changed_status: sender)
    }
    
    func update(status_title: String?, enable: Bool) {
        status.setTitle(
            status_title,
            for: .normal
        )
        status.isEnabled = enable
    }
}


//    // MARK: Type Buttons
//
//    @IBOutlet weak var info_type_server_button: UIButton!
//    @IBOutlet weak var info_type_client_button: UIButton!
//    @IBOutlet weak var info_type_udp_button: UIButton!
//    @IBAction func info_type_actions(_ sender: UIButton) {
//        model.type = SocketModel.SocketType(rawValue: sender.tag)!
//
//        info_type_server_button.isSelected = sender.tag == 0
//        info_type_client_button.isSelected = sender.tag == 1
//        info_type_udp_button.isSelected    = sender.tag == 2
//
//        update_address_port_enabled()
//        update_status_button()
//        update_type_button()
//    }
//
//    func update_type_button() {
//        switch model.type {
//        case .server:
//            info_type_server_button.setImage(#imageLiteral(resourceName: "type_server_open"), for: .normal)
//            info_type_client_button.setImage(#imageLiteral(resourceName: "type_client_close"), for: .normal)
//            info_type_udp_button.setImage(#imageLiteral(resourceName: "type_udp_close"), for: .normal)
//        case .client:
//            info_type_server_button.setImage(#imageLiteral(resourceName: "type_server_close"), for: .normal)
//            info_type_client_button.setImage(#imageLiteral(resourceName: "type_client_open"), for: .normal)
//            info_type_udp_button.setImage(#imageLiteral(resourceName: "type_udp_close"), for: .normal)
//        case .udp:
//            info_type_server_button.setImage(#imageLiteral(resourceName: "type_server_close"), for: .normal)
//            info_type_client_button.setImage(#imageLiteral(resourceName: "type_client_close"), for: .normal)
//            info_type_udp_button.setImage(#imageLiteral(resourceName: "type_udp_open"), for: .normal)
//        }
//    }
//
//    func update_type_enable() {
//        var enable = true
//        switch model.type {
//        case .server:
//            enable = model.local.socket == nil
//        case .client:
//            enable = model.remote.socket == nil
//        case .udp:
//            enable = model.local.socket == nil
//        }
//
//        info_type_server_button.isEnabled = enable
//        info_type_client_button.isEnabled = enable
//        info_type_udp_button.isEnabled    = enable
//
//        if enable {
//            layout_ready_to_connect()
//        }
//        else {
//            layout_ready_to_input()
//        }
//    }
//
//    // MARK: Address and Port
//
//    @IBOutlet weak var local_address_button: UIButton!
//    @IBOutlet weak var local_port_button: UIButton!
//    @IBAction func local_address_action(_ sender: UIButton) {
//        update_message_info(.local_address)
//    }
//    @IBAction func local_port_action(_ sender: UIButton) {
//        update_message_info(.local_port)
//    }
//
//    @IBOutlet weak var remote_address_button: UIButton!
//    @IBOutlet weak var remote_port_button: UIButton!
//    @IBAction func remote_address_action(_ sender: UIButton) {
//        update_message_info(.remote_address)
//    }
//    @IBAction func remote_port_action(_ sender: UIButton) {
//        update_message_info(.remote_port)
//    }
//
//    func update_address_port_title() {
//        local_address_button.setTitle(
//            model.local.address,
//            for: .normal
//        )
//        local_port_button.setTitle(
//            model.local.port.description,
//            for: .normal
//        )
//        remote_address_button.setTitle(
//            model.remote.address,
//            for: .normal
//        )
//        remote_port_button.setTitle(
//            model.remote.port.description,
//            for: .normal
//        )
//    }
//
//    func update_address_port_enabled() {
//        switch model.type {
//        case .server:
//            if model.local.socket == nil {
//                local_address_button.isEnabled  = false
//                local_port_button.isEnabled     = true
//                remote_address_button.isEnabled = false
//                remote_port_button.isEnabled    = false
//            }
//            else {
//                local_address_button.isEnabled  = false
//                local_port_button.isEnabled     = false
//                remote_address_button.isEnabled = false
//                remote_port_button.isEnabled    = false
//            }
//        case .client:
//            if model.remote.socket == nil {
//                local_address_button.isEnabled  = false
//                local_port_button.isEnabled     = false
//                remote_address_button.isEnabled = true
//                remote_port_button.isEnabled    = true
//            }
//            else {
//                local_address_button.isEnabled  = false
//                local_port_button.isEnabled     = false
//                remote_address_button.isEnabled = false
//                remote_port_button.isEnabled    = false
//            }
//        case .udp:
//            if model.local.socket == nil {
//                local_address_button.isEnabled  = false
//                local_port_button.isEnabled     = true
//                remote_address_button.isEnabled = true
//                remote_port_button.isEnabled    = true
//            }
//            else {
//                local_address_button.isEnabled  = false
//                local_port_button.isEnabled     = false
//                remote_address_button.isEnabled = true
//                remote_port_button.isEnabled    = true
//            }
//        }
//    }
//
//    // MARK: Connect Close Accpeting
//
//    @IBOutlet weak var socket_status_button: UIButton!
//    @IBAction func socket_status_action(_ sender: UIButton) {
//        if sender.title(for: .normal) == "Close" {
//            AppData.shared.close()
//        }
//        else {
//            AppData.shared.connect()
//        }
//    }
//
//    func update_status_button() {
//        switch model.type {
//        case .server:
//            if model.local.socket == nil {
//                socket_status_button.isEnabled = true
//                socket_status_button.setTitle(
//                    "Bind".localisation,
//                    for: .normal
//                )
//            }
//            else if model.remote.socket == nil {
//                socket_status_button.isEnabled = false
//                socket_status_button.setTitle(
//                    "Accpeting".localisation,
//                    for: .normal
//                )
//            }
//            else {
//                socket_status_button.isEnabled = true
//                socket_status_button.setTitle(
//                    "Close".localisation,
//                    for: .normal
//                )
//            }
//        case .client:
//            if model.remote.socket == nil {
//                socket_status_button.isEnabled = true
//                socket_status_button.setTitle(
//                    "Connect".localisation,
//                    for: .normal
//                )
//            }
//            else {
//                socket_status_button.isEnabled = true
//                socket_status_button.setTitle(
//                    "Close".localisation,
//                    for: .normal
//                )
//            }
//        case .udp:
//            if model.local.socket == nil {
//                socket_status_button.isEnabled = true
//                socket_status_button.setTitle(
//                    "Bind".localisation,
//                    for: .normal
//                )
//            }
//            else {
//                socket_status_button.isEnabled = true
//                socket_status_button.setTitle(
//                    "Close".localisation,
//                    for: .normal
//                )
//            }
//        }
//    }

//
//  ListCell.swift
//  SocketChat
//
//  Created by Myron on 2017/4/22.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

class ListCell: UITableViewCell {

    @IBOutlet weak var local_info: UILabel!
    @IBOutlet weak var remote_info: UILabel!
    @IBOutlet weak var type_image: UIImageView!
    
    func update(_ value: SocketModel) {
        local_info.text = "\(value.local.address) : \(value.local.port)"
        remote_info.text = "\(value.remote.address) : \(value.remote.port)"
        switch value.type {
        case .server:
            if value.local.socket == nil {
                type_image.image = UIImage(named: "type_server_close")
            }
            else {
                type_image.image = UIImage(named: "type_server_open")
            }
        case .client:
            if value.remote.socket == nil {
                type_image.image = UIImage(named: "type_client_close")
            }
            else {
                type_image.image = UIImage(named: "type_client_open")
            }
        case .udp:
            if value.local.socket == nil {
                type_image.image = UIImage(named: "type_udp_close")
            }
            else {
                type_image.image = UIImage(named: "type_udp_open")
            }
        }
    }
    
}

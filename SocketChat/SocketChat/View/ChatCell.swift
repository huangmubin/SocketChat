//
//  ChatCell.swift
//  SocketChat
//
//  Created by Myron on 2017/4/22.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    func update(_ value: EventModel) {
        messageLabel.text = value.message_note()
        messageLabel.sizeToFit()
        
        nameLabel?.text = value.message_ip()
        nameLabel?.sizeToFit()
    }

}

class ChatCell0: ChatCell {
    
    
}
class ChatCell1: ChatCell {
    
    
}
class ChatCell2: ChatCell {
    
    
}

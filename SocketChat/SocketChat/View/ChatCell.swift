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
    
    func update(_ value: EventModel) {
        messageLabel.text = value.toString()
        messageLabel.sizeToFit()
    }

}

class ChatCell0: ChatCell {
    
    
}
class ChatCell1: ChatCell {
    
    
}
class ChatCell2: ChatCell {
    
    
}

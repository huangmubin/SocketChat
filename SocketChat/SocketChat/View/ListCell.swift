//
//  ListCell.swift
//  SocketChat
//
//  Created by Myron on 2017/4/22.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

class ListCell: UITableViewCell {

    @IBOutlet weak var id_label: UILabel!
    
    func update(_ value: SocketModel) {
        id_label.text = value.id
    }
    
}

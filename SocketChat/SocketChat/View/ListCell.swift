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
    @IBOutlet weak var type_label: UILabel!
    
    func update(_ value: SocketModel) {
        id_label.text = value.id
        type_label.text = value.type.toString()
    }
    
}

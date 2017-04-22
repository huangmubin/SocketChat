//
//  SocketData.swift
//  SocketChat
//
//  Created by Myron on 2017/4/22.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

class SocketModel: Socket {
    
    var id: String = "New Socket"
    var events: [EventModel] = [EventModel()]
    
    var isConnecting = false
    
}

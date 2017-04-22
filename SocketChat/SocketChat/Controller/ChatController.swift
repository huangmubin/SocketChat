//
//  ChatController.swift
//  SocketChat
//
//  Created by 黄穆斌 on 2017/4/22.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

class ChatController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inputview.update_buttons(
            isCreated: AppData.shared.current.socket != nil,
            isConneting: AppData.shared.current.isConnecting
        )
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.estimatedRowHeight = 30
        }
    }
    @IBOutlet weak var inputview: InputView!
    @IBOutlet weak var layout_inputview_bottom: NSLayoutConstraint!
    
}

// MARK: - TableView

extension ChatController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppData.shared.current.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = AppData.shared.current.events[indexPath.row]
        switch data.from {
        case .system:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell0", for: indexPath) as! ChatCell0
            cell.update(data)
            return cell
        case .local:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell1", for: indexPath) as! ChatCell1
            cell.update(data)
            return cell
        case .remote:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell2", for: indexPath) as! ChatCell2
            cell.update(data)
            return cell
        }
    }

    
}

// MARK: - Input View

extension ChatController: InputViewDelegate {
    
    func inputview(connect_action inputview: InputView) {
        
    }
    
    func inputview(send_action inputview: InputView) {
        
    }
    
}

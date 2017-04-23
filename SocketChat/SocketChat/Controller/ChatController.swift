//
//  ChatController.swift
//  SocketChat
//
//  Created by 黄穆斌 on 2017/4/22.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

class ChatController: UIViewController, NotifierProtocol {

    override func viewDidLoad() {
        super.viewDidLoad()
        observer(name: .SocketUpdate, selector: #selector(notification(notify:)), object: AppData.shared)
        observer(name: NSNotification.Name.UIKeyboardWillChangeFrame, selector: #selector(keyboard_notification(notify:)))
        
        tableview_scroll_to_bottom()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        inputview.update_buttons(
            isCreated: AppData.shared.current.socket != nil,
            isConneting: AppData.shared.current.isConnecting
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        inputview.message_text.resignFirstResponder()
    }
    
    deinit {
        unobserver()
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.estimatedRowHeight = 24
        }
    }
    @IBOutlet weak var inputview: InputView! {
        didSet {
            inputview.delegate = self
        }
    }
    @IBOutlet weak var layout_inputview_bottom: NSLayoutConstraint!
    
    func keyboard_notification(notify: Notification) {
        if let rect = notify.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            //print("view = \(self.view.bounds.height); \nrect = \(rect.cgRectValue.origin.y); \(rect.cgRectValue.height);\ninput = \(inputview.bounds.height)")
            let height = self.view.bounds.height - rect.cgRectValue.origin.y + 64
            UIView.animate(withDuration: 0.25, animations: {
                self.layout_inputview_bottom.constant = height
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // MARK: Touch
    
    @IBAction func gesture_tap_view_action(_ sender: UITapGestureRecognizer) {
        inputview.message_text.resignFirstResponder()
    }
    
}

// MARK: - TableView

extension ChatController: UITableViewDataSource, UITableViewDelegate {
    
    func tableview_scroll_to_bottom() {
        DispatchQueue.main.async {
            if self.tableView.numberOfRows(inSection: 0) > 0 {
                let index = IndexPath(row: self.tableView.numberOfRows(inSection: 0) - 1, section: 0)
                self.tableView.scrollToRow(at: index, at: .bottom, animated: true)
            }
        }
    }
    
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppData.shared.current.events[indexPath.row].isNote = !AppData.shared.current.events[indexPath.row].isNote
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
}

// MARK: - Input View

extension ChatController: InputViewDelegate {
    
    func inputview(connect_action inputview: InputView) {
        AppData.shared.connect()
    }
    
    func inputview(send_action inputview: InputView) {
        if inputview.isText() {
            AppData.shared.send(text: inputview.text()!)
        }
        else {
            AppData.shared.send(bytes: inputview.value()!)
        }
        inputview.message_text.text = nil
        inputview.message_text_changed(inputview.message_text)
    }
    
}

// MARK: - Notification

extension ChatController {
    
    func notification(notify: Notification) {
        self.tableView.reloadData()
        self.inputview.update_buttons(
            isCreated: AppData.shared.current.socket != nil,
            isConneting: AppData.shared.current.isConnecting
        )
        tableview_scroll_to_bottom()
    }
    
}
    

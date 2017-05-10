//
//  ChatController.swift
//  SocketChat
//
//  Created by 黄穆斌 on 2017/4/22.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

class ChatController: UIViewController,
                      NotifierProtocol,
                      UITableViewDataSource,
                      UITableViewDelegate,
                      UITextViewDelegate,
                      SocketInfoViewDelegate,
                      AddressInputViewDelegate,
                      MessageEditViewDelegate
    
{

    var model: SocketModel!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model = AppData.shared.current
        
        layout_ready_to_connect(false)
        
        // Update the views
        if socket_info_view.update(model: model) {
            layout_ready_to_connect(true)
        }
        else {
            layout_ready_to_input(true)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observer(
            name: .SocketConnect,
            selector: #selector(notification_connect(notify:))
        )
        observer(
            name: .SocketUpdate,
            selector: #selector(notification_event(notify:))
        )
        observer(
            name: .UIKeyboardWillChangeFrame,
            selector: #selector(notification_keyboard(notify:))
        )
    }
    
    deinit {
        unobserver()
    }
    
    // MARK: - TableView
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.estimatedRowHeight = 200
            self.tableView.rowHeight = UITableViewAutomaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let event = model.events[indexPath.row]
        switch event.from {
        case .system:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatSystem", for: indexPath) as! ChatCell0
            cell.messageLabel.text = event.note
            return cell
        case .remote:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatRemote", for: indexPath) as! ChatCell1
            cell.messageLabel.text = event.note
            cell.timesLabel.text = event.times > 1 ? "+ \(event.times)" : ""
            cell.sizeLabel.text = "\(event.data.count) bytes"
            return cell
        case .local:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatLocal", for: indexPath) as! ChatCell2
            cell.messageLabel.text = event.note
            cell.timesLabel.text = event.times > 1 ? "\(event.times) +" : ""
            cell.sizeLabel.text = "\(event.data.count) bytes"
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = model.events[indexPath.row]
        switch event.from {
        case .system:
            break
        case .local, .remote:
            switch event.type {
            case .note:
                event.type = .i_16
            case .i_16:
                event.type = .i_10
            case .i_10:
                event.type = .note
            }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
    }
    
    // MARK: - Layouts
    
    @IBOutlet weak var layout_message_bottom: NSLayoutConstraint!
    @IBOutlet weak var layout_message_height: NSLayoutConstraint!
    @IBOutlet weak var layout_menu_top: NSLayoutConstraint!
    @IBOutlet weak var layout_input_top: NSLayoutConstraint! {
        didSet {
            layout_input_top.constant = UIScreen.main.bounds.height
        }
    }
    
    func layout_ready_to_connect(_ animatie: Bool = true) {
        UIView.animate(
            withDuration: animatie ? 0.25 : 0,
            animations: {
            self.layout_message_bottom.constant = 149
            self.layout_menu_top.constant = -51
            self.view.layoutIfNeeded()
        })
    }
    
    func layout_ready_to_input(_ animatie: Bool = true) {
        UIView.animate(
            withDuration: animatie ? 0.25 : 0,
            animations: {
            self.layout_message_bottom.constant = 0
            self.layout_menu_top.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
    func layout_input_address(show: Bool) {
        let time: Double = show ? 0.25 : 0.5
        let constant = show ? 0 : UIScreen.main.bounds.height
        UIView.animate(
            withDuration: time,
            animations: {
                self.layout_input_top.constant = constant
                self.view.layoutIfNeeded()
        })
    }
    
    // MARK: - Message View
    
    @IBOutlet weak var message_edit_view: MessageEditView! {
        didSet {
            message_edit_view.delegate = self
        }
    }
    
    func message_edit_action(_ sender: UIButton) {
        UIView.animate(withDuration: 0.25, animations: {
            self.layout_message_bottom.constant = 200
            self.view.layoutIfNeeded()
        })
    }
    
    func message_send_action(_ sender: UIButton, text: String) {
        AppData.shared.send(text: text)
    }
    
    func message_textview_change(_ textView: UITextView, height: CGFloat) {
        
    }
    
    // MARK: - Socket Info
    
    @IBOutlet weak var socket_info_view: SocketInfoView! {
        didSet {
            socket_info_view.delegate = self
        }
    }
    
    func socket_info(changed_type sender: UIButton) {
        model.type = SocketModel.SocketType(rawValue: sender.tag)!
    }
    
    func socket_info(changed_info sender: UIButton) {
        switch sender.tag {
        case 0:
            address_input_view.update_message_info(
                AddressInputView.InputType.local_address(
                    model.local.address
                )
            )
        case 1:
            address_input_view.update_message_info(
                AddressInputView.InputType.local_port(
                    model.local.port
                )
            )
        case 2:
            address_input_view.update_message_info(
                AddressInputView.InputType.remote_address(
                    model.remote.address
                )
            )
        case 3:
            address_input_view.update_message_info(
                AddressInputView.InputType.remote_port(
                    model.remote.port
                )
            )
        default: break
        }
        layout_input_address(show: true)
    }
    
    func socket_info(changed_status sender: UIButton) {
        if sender.title(for: .normal) == "Close" {
            AppData.shared.close()
        }
        else {
            AppData.shared.connect()
        }
    }
    
    
    // MARK: - Address Input View
    
    @IBOutlet weak var address_input_view: AddressInputView! {
        didSet {
            address_input_view.delegate = self
        }
    }
    
    func address_input_save_action(type: Int, text: String) {
        switch type {
        case 0:
            model.local.address = text
            socket_info_view.local_addr.setTitle(
                text,
                for: .normal
            )
        case 1:
            model.local.port = Int32(text)!
            socket_info_view.local_port.setTitle(
                text,
                for: .normal
            )
        case 2:
            model.remote.address = text
            socket_info_view.remote_addr.setTitle(
                text,
                for: .normal
            )
        case 3:
            model.remote.port = Int32(text)!
            socket_info_view.remote_port.setTitle(
                text,
                for: .normal
            )
        default: break
        }
        layout_input_address(show: false)
    }
    
    // MARK: - Notification
    
    func notification_event(notify: Notification) {
        if notify.get("flag", null: -1) == model.flag {
            let rows = tableView.numberOfRows(inSection: 0)
            let count = model.events.count
            if rows < count {
                print("now = \(rows); count = \(count)")
                var indexes = [IndexPath]()
                for i in rows ..< count {
                    indexes.append(IndexPath(row: i, section: 0))
                    print("i = \(i)")
                }
                tableView.insertRows(at: indexes, with: .automatic)
                print("insert")
                print("tableview = \(tableView.isExclusiveTouch) \(tableView.isFirstResponder)")
                if indexes.count > 0 {
                    tableView.scrollToRow(
                        at: indexes.last!,
                        at: .bottom,
                        animated: true
                    )
                }
            }
        }
    }
    
    func notification_connect(notify: Notification) {
        if notify.get("flag", null: -1) == model.flag {
            if socket_info_view.update(model: model) {
                layout_ready_to_connect(true)
            }
            else {
                layout_ready_to_input(true)
            }
        }
    }
    
    func notification_keyboard(notify: Notification) {
        if let rect = notify.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            if rect.cgRectValue.origin.y == UIScreen.main.bounds.height {
                // Close Keyboard
            }
            else {
                // Open Keyboard
                if message_edit_view.input_textview.isFirstResponder {
                    UIView.animate(withDuration: 0.25, animations: {
                        self.layout_message_bottom.constant = rect.cgRectValue.height
                        self.view.layoutIfNeeded()
                    })
                }
            }
        }
    }
}

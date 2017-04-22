//
//  ListController.swift
//  SocketChat
//
//  Created by 黄穆斌 on 2017/4/22.
//  Copyright © 2017年 myron. All rights reserved.
//

import UIKit

class ListController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppData.shared.datas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell", for: indexPath) as! ListCell
        cell.update(AppData.shared.datas[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppData.shared.current = AppData.shared.datas[indexPath.row]
    }
    
    // MARK: - Add
    
    @IBAction func addAction(_ sender: UIBarButtonItem) {
        let socket = SocketModel()
        AppData.shared.datas.append(socket)
        tableView.reloadData()
    }
    
}

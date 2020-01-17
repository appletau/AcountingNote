//
//  SwipeTableViewController.swift
//  Accounting note
//
//  Created by tautau on 2018/8/24.
//  Copyright © 2018年 tautau. All rights reserved.
//

import UIKit
import SwipeCellKit
import RealmSwift

class SwipeTableViewController: UITableViewController {
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .normal, title: "delete") { action, index in
            self.updateModel(atIndexPath: index)
        }
        deleteAction.backgroundColor = UIColor.red
        return [deleteAction]
    }
    
//
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
//        guard orientation == .right else { return nil }
//        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
//            self.updateModel(atIndexPath: indexPath)
//        }
//        deleteAction.image = UIImage(named: "delete")
//
//        return [deleteAction]
//    }
//
//    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
//        var options = SwipeOptions()
//        options.expansionStyle = .destructive
//        options.transitionStyle = .border
//        return options
//    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) //as! SwipeTableViewCell
        //cell.delegate = self
        return cell
    }
    
    func updateModel(atIndexPath:IndexPath){
        
    }
}

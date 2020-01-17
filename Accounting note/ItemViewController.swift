//
//  DailyCostController.swift
//  Accounting note
//
//  Created by tautau on 2018/8/21.
//  Copyright © 2018年 tautau. All rights reserved.
//

import UIKit
import RealmSwift



class ItemViewController: SwipeTableViewController{
    
    @IBOutlet var spendLabel: UILabel!
    @IBOutlet var incomeLabel: UILabel!
    @IBOutlet var balanceLabel: UILabel!
    
    let headerSectionTag: Int = 1;
    var expandedSectionHeaderNumber: Int = -1
    var expandedSectionHeader: UITableViewHeaderFooterView!
    var sectionHeaderNames: Array<Any> = ["expenditure","income"]
    
    var itemContainer:Results<Item>?
    var itemsChangeNotification:NotificationToken?
    var selectedDateChangeNotification:NotificationToken?
    var selectedDate : DayInfo?{
        didSet{
            itemContainer = selectedDate?.items.sorted(byKeyPath: "category", ascending: true)
            title = "\(selectedDate!.parentMonth[0].month) \(selectedDate!.day)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let headerTitles = [ButtonTitleOfKeyBoard()["Row1OfSpendedItem"],
                            ButtonTitleOfKeyBoard()["Row2OfSpendedItem"],
                            ButtonTitleOfKeyBoard()["Row3OfSpendedItem"],
                            ButtonTitleOfKeyBoard()["Row4OfSpendedItem"],
                            ButtonTitleOfKeyBoard()["Row5OfSpendedItem"],
                            ButtonTitleOfKeyBoard()["Row1OfIncomeItem"],
                            ButtonTitleOfKeyBoard()["Row2OfIncomeItem"]]
        updateTableViewSectionHeader(withArrayOfRow:headerTitles)
        tableView.rowHeight = 80.0
        
        spendLabel.text = "Spend:\(selectedDate!.totalSpend)"
        incomeLabel.text = "Income:\(selectedDate!.totalIncome)"
        balanceLabel.text = "Balance:\(selectedDate!.totalBalance)"
        itemsChangeNotification = itemContainer?.observe({ (changes) in
            switch changes{
            case .initial(_):
                break
            case .update(_, _, _, _):
                self.sectionHeaderNames = ["expenditure","income"]
                self.updateTableViewSectionHeader(withArrayOfRow:headerTitles)
                self.tableView.reloadData()
            case .error(let error):
                print(error)
            }
        })
        selectedDateChangeNotification = selectedDate?.observe({ (changes) in
            switch changes{
            case .error(let error):
                print(error)
            case .change(_):
                self.spendLabel.text = "Spend:\(self.selectedDate!.totalSpend)"
                self.incomeLabel.text = "Income:\(self.selectedDate!.totalIncome)"
                self.balanceLabel.text = "Balance:\(self.selectedDate!.totalBalance)"
            case .deleted:
                break
            }
        })
    }
    
    deinit{
        itemsChangeNotification?.invalidate()
        selectedDateChangeNotification?.invalidate()
    }
    
    func updateTableViewSectionHeader (withArrayOfRow keyboardBtnTitle:[Array<String>]){
        for rowOfBtnTitles in keyboardBtnTitle{
            for category in rowOfBtnTitles{
                guard let items = itemContainer?.filter("category CONTAINS[cd] %@",category) else{fatalError("Realm Get Item fail")}
                if items.isEmpty{continue}
                if items.first?.incomeOrCost == 0
                {
                    sectionHeaderNames.insert(category, at: 1)
                }else{
                    sectionHeaderNames.append(category)
                }
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.expandedSectionHeaderNumber == section) {
            let sectionItems = itemContainer?.filter("category CONTAINS[cd] %@",sectionHeaderNames[section])
            return sectionItems!.count
        } else {
            return 0;
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if sectionHeaderNames.count > 0 {
            return sectionHeaderNames.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (self.sectionHeaderNames.count != 0) {
            return self.sectionHeaderNames[section] as? String
        }
        return ""
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat{
        return 2;
    }
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView:UIView
        let titleLabel:UILabel
        let title = sectionHeaderNames[section] as! String
        let createHeaderView = {(viewSize:CGRect,backGroundColor:UIColor)->UIView in
            let view = UIView(frame:viewSize)
            view.backgroundColor = backGroundColor
            return view
        }
        let createTitleLabel = {(labelSize:CGRect,textColor:UIColor,textSize:CGFloat) -> UILabel in
            let label = UILabel(frame: labelSize)
            label.textColor = textColor
            label.font = UIFont.boldSystemFont(ofSize: textSize)
            label.text = title
            return label
        }
        
        if title == "expenditure" || title == "income"{
            headerView = createHeaderView(CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 40),UIColor(red: 100/255.0, green: 100/255.0, blue: 100/255.0, alpha: 1))
            titleLabel = createTitleLabel(CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: 40),UIColor.white,20)
        }else{
            headerView = createHeaderView(CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 20),UIColor(red: 253.0/255.0, green: 240.0/255.0, blue: 196.0/255.0, alpha: 1))
            titleLabel = createTitleLabel(CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: 20),UIColor.black,15)
            let chevronImage:UIImageView = {
                let imageView = UIImageView(frame: CGRect(x: headerView.frame.size.width - 32, y: headerView.frame.minY+5, width: 10, height: 10));
                imageView.image = UIImage(named: "Chevron-Dn-Wht")
                imageView.tag = headerSectionTag + section
                return imageView
            }()
            
            headerView.addSubview(chevronImage)
            let headerTapGesture = UITapGestureRecognizer()
            headerTapGesture.addTarget(self, action: #selector(sectionHeaderWasTouched(_:)))
            headerView.addGestureRecognizer(headerTapGesture)
        }
        headerView.addSubview(titleLabel)
        
        if let viewWithTag = self.view.viewWithTag(headerSectionTag + section) {
            viewWithTag.removeFromSuperview()
        }
        headerView.tag = section
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let headerName = sectionHeaderNames[section] as! String
        if headerName == "expenditure" || headerName == "income"{
            return 40
        }else{
            return 20
        }
    }
    @objc func sectionHeaderWasTouched(_ sender: UITapGestureRecognizer) {
        guard let headerView = sender.view else {return}//UITableViewHeaderFooterView
        let section    = headerView.tag
        let chevronImageView = headerView.viewWithTag(headerSectionTag + section) as? UIImageView
        if (self.expandedSectionHeaderNumber == -1) {
            self.expandedSectionHeaderNumber = section
            tableViewExpandSection(section, imageView: chevronImageView!)
        } else {
            if (self.expandedSectionHeaderNumber == section) {
                tableViewCollapeSection(section, imageView: chevronImageView!)
            } else {
                let chevronImageViewToClose = self.view.viewWithTag(headerSectionTag + self.expandedSectionHeaderNumber) as? UIImageView
                tableViewCollapeSection(self.expandedSectionHeaderNumber, imageView: chevronImageViewToClose!)
                tableViewExpandSection(section, imageView: chevronImageView!)
            }
        }
    }
    func tableViewExpandSection(_ section: Int, imageView: UIImageView) {
        guard let sectionItems = itemContainer?.filter("category CONTAINS[cd] %@",sectionHeaderNames[section])else{fatalError("Realm get items Fail")}
        if (sectionItems.count == 0) {
            self.expandedSectionHeaderNumber = -1;
            return;
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                imageView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionItems.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.expandedSectionHeaderNumber = section
            self.tableView!.beginUpdates()
            self.tableView!.insertRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.tableView!.endUpdates()
        }
    }
    
    func tableViewCollapeSection(_ section: Int, imageView: UIImageView) {
        guard let sectionItems = itemContainer?.filter("category CONTAINS[cd] %@",sectionHeaderNames[section])else{fatalError("Realm get items Fail")}
        self.expandedSectionHeaderNumber = -1;
        if (sectionItems.count == 0) {
            return;
        } else {
            UIView.animate(withDuration: 0.4, animations: {
                imageView.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(Double.pi)) / 180.0)
            })
            var indexesPath = [IndexPath]()
            for i in 0 ..< sectionItems.count {
                let index = IndexPath(row: i, section: section)
                indexesPath.append(index)
            }
            self.tableView!.beginUpdates()
            self.tableView!.deleteRows(at: indexesPath, with: UITableViewRowAnimation.fade)
            self.tableView!.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! ItemTableViewCell
        guard let sectionItems = itemContainer?.filter("category CONTAINS[cd] %@",sectionHeaderNames[indexPath.section])else{fatalError("Realm get items Fail")}
        cell.itemSpend.text = sectionItems[indexPath.row].amount
        cell.itemType.text = sectionItems[indexPath.row].category
        cell.cellImageView.image = UIImage(data:sectionItems[indexPath.row].image)
        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToEditItem", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? UpdateItemViewController else{fatalError("Can not go to UpdateItemViewController")}
        vc.dateString = title
        if segue.identifier == "goToEditItem"{
            guard let indexPath = tableView.indexPathForSelectedRow else {fatalError("Get tableView index faild")}
            vc.editItem = itemContainer?.filter("category CONTAINS[cd] %@",sectionHeaderNames[indexPath.section])[indexPath.row]
        }
    }
    
    // MARK: - UI Action
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToAddNewItem", sender: self)
    }
    
    // MARK: - Realm update data
    
    override func updateModel(atIndexPath: IndexPath) {
        do{
           // print("section__\(atIndexPath.section),row__\(atIndexPath.row)")
            
            guard let deletedItem = itemContainer?.filter("category CONTAINS[cd] %@",sectionHeaderNames[atIndexPath.section])[atIndexPath.row]else{fatalError("Object is nill at \(atIndexPath.row) in itemContainer")}
            try realm.write {
                if deletedItem.incomeOrCost == 0{
                    selectedDate?.totalSpend -= Int(deletedItem.amount)!
                    spendLabel.text = "Spend:\(selectedDate!.totalSpend)"
                }else{
                    selectedDate?.totalIncome -= Int(deletedItem.amount)!
                    incomeLabel.text = "Income:\(selectedDate!.totalIncome)"
                }
            }
            try realm.write {realm.delete(deletedItem)}
        }catch{
            print("delete item failed,\(error)")
        }
    }
    
    // MARK: - Resize UIImage
    /*
     func resizeUIImage(image: UIImage, newWidth: CGFloat) -> UIImage {
     let scale = newWidth / image.size.width
     let newHeight = image.size.height * scale
     UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
     image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
     let newImage = UIGraphicsGetImageFromCurrentImageContext()
     UIGraphicsEndImageContext()
     
     return newImage!
     }
     */
}







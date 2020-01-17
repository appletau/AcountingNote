//
//  MonthlyCostController.swift
//  Accounting note
//
//  Created by tautau on 2018/8/21.
//  Copyright © 2018年 tautau. All rights reserved.
//

import UIKit
import RealmSwift
import DatePickerDialog


class DateViewController: SwipeTableViewController {
    
    @IBOutlet var spendLabel: UILabel!
    @IBOutlet var incomeLabel: UILabel!
    @IBOutlet var balanceLabel: UILabel!
    var dateContainer:Results<DayInfo>?
    var monthlyInfo:Results<MonthlyInfo>?
    var notificationToken: NotificationToken?
    var selectedMonth:String?{
        didSet{
            monthlyInfo = realm.objects(MonthlyInfo.self).filter("month CONTAINS[cd] %@",selectedMonth!)
            if monthlyInfo!.isEmpty {
                let newMonthlyInfo = MonthlyInfo(value: [selectedMonth!,0,0,0])
                print(newMonthlyInfo.month)
                do{try realm.write {realm.add(newMonthlyInfo)}}
                catch{print("Create monthlyInfo error,\(error)")}
            }
        }
    }
    let dateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        formatter.locale = Locale(identifier: "en_US")
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        return formatter
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 40.0
        title = selectedMonth
        spendLabel.text = "Spend:\(monthlyInfo![0].totalSpend)"
        incomeLabel.text = "Income:\(monthlyInfo![0].totalIncome)"
        balanceLabel.text = "Balance:\(monthlyInfo![0].totalBalance)"
        
        notificationToken = monthlyInfo?[0].days.observe({ (changes) in
            switch changes {
            case .initial(_):
                break
            case .update(_, let deletion, let insertions, let modifications):
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) },with: .automatic)
                self.tableView.deleteRows(at: deletion.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) },with: .automatic)
                self.tableView.endUpdates()
                self.spendLabel.text = "Spend:\(self.monthlyInfo![0].totalSpend)"
                self.incomeLabel.text = "Income:\(self.monthlyInfo![0].totalIncome)"
                self.balanceLabel.text = "Balance:\(self.monthlyInfo![0].totalBalance)"
            case .error(let error):
                print(error)
            }
        })
    }
    
    deinit{
        notificationToken?.invalidate()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monthlyInfo![0].days.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.textLabel?.text = monthlyInfo![0].month + monthlyInfo![0].days[indexPath.row].day
        return cell
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToDailyCost", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! ItemViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            vc.selectedDate = monthlyInfo![0].days[indexPath.row]
        }
    }
    
    // MARK: - Realm update data
    override func updateModel(atIndexPath: IndexPath) {
        do{
            let row = atIndexPath.row
            try realm.write {
                monthlyInfo![0].days.remove(at: row)
            }
        }catch{
            print("delete date failed,\(error)")
        }
    }
    
    // MARK: - UI Actiond
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        guard let defaultDate = dateFormatter.date(from: "\(selectedMonth!) 01, 2020")else {fatalError("Set default date error")}
        guard let maximumDate = self.caculatemaximumDate(ofMonth:selectedMonth!, startDate: defaultDate) else {fatalError("Set maximum date error")}
 
        DatePickerDialog().show("DatePicker",
                                doneButtonTitle: "Done",
                                cancelButtonTitle: "Cancel",
                                defaultDate: defaultDate,
                                minimumDate: defaultDate,
                                maximumDate: maximumDate,
                                datePickerMode: .date)
        { (date) in
            let dateArray = self.dateFormatter.string(from: date!).split(separator:",")[0].split(separator: " ")
            let day = String(dateArray[1])
            let dateInRealm = self.monthlyInfo?.first?.days.filter("day CONTAINS[cd] %@",day)
            if (dateInRealm?.isEmpty)!
            {
                let dailySpend = DayInfo(value: [day,0,0,0])
                do{
                    try self.realm.write {
                        self.monthlyInfo?.first?.days.append(dailySpend)
                    }
                }catch{
                    print("Add date error,\(error)")
                }
                
            }
        }
    }
    // MARK: - Assistant Function
    func caculatemaximumDate(ofMonth month:String,startDate:Date)->Date?
    {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        if let numDays = calendar.range(of: .day, in: .month, for: calendar.startOfDay(for: startDate))?.count
        {
            guard let maximumDate = dateFormatter.date(from: "\(month) \(numDays), \(year)")else {fatalError("Set maximum date error")}
            return maximumDate
        }
        return nil
    }
}

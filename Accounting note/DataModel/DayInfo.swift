//
//  DailySpend.swift
//  Accounting note
//
//  Created by tautau on 2018/8/21.
//  Copyright © 2018年 tautau. All rights reserved.
//

import Foundation
import RealmSwift

class DayInfo:Object {

    //@objc dynamic var month:String = ""
    @objc dynamic var day:String = ""
    @objc dynamic var totalSpend:Int = 0
    @objc dynamic var totalIncome:Int = 0
    @objc dynamic var totalBalance:Int = 0
    let items = List<Item>()
    let parentMonth = LinkingObjects(fromType: MonthlyInfo.self, property: "days")
    //    @objc dynamic var id = 0
//    override static func primaryKey() -> String? {
//        return "id"
//    }
}

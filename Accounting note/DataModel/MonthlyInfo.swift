//
//  MonthlyInfo.swift
//  Accounting note
//
//  Created by tautau on 2018/9/18.
//  Copyright © 2018年 tautau. All rights reserved.
//

import Foundation
import RealmSwift
class MonthlyInfo:Object{
    @objc dynamic var month:String = ""
    @objc dynamic var totalSpend:Int = 0
    @objc dynamic var totalIncome:Int = 0
    @objc dynamic var totalBalance:Int = 0
    let days = List<DayInfo>()
}

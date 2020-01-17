//
//  TestView.swift
//  Accounting note
//
//  Created by tautau on 2018/9/26.
//  Copyright © 2018年 tautau. All rights reserved.
//
import UIKit

class CustomKeyboardView: UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let name = Notification.Name("segmentControlValueChanged")
        NotificationCenter.default.addObserver(self, selector: #selector(segmentedControlSwitch), name:name, object: nil)
        let view = CreateKeyboard.createKeyboard(withArrayOfButtonRow: [ButtonTitleOfKeyBoard()["Row1OfSpendedItem"],
                                        ButtonTitleOfKeyBoard()["Row2OfSpendedItem"],
                                        ButtonTitleOfKeyBoard()["Row3OfSpendedItem"],
                                        ButtonTitleOfKeyBoard()["Row4OfSpendedItem"],
                                        ButtonTitleOfKeyBoard()["Row5OfSpendedItem"]])
        
        self.addSubview(view)
    }
    
    
    
    @objc func segmentedControlSwitch(notification: NSNotification)
    {
        subviews.forEach({ $0.removeFromSuperview() })
        //subviews.map({ $0.removeFromSuperview() })
        let userInfo = notification.userInfo
        let segmentControlValue = userInfo!["segmentControlValue"] as! Int
        
        if segmentControlValue == 0{
         let view = CreateKeyboard.createKeyboard(withArrayOfButtonRow: [ButtonTitleOfKeyBoard()["Row1OfSpendedItem"],
                                            ButtonTitleOfKeyBoard()["Row2OfSpendedItem"],
                                            ButtonTitleOfKeyBoard()["Row3OfSpendedItem"],
                                            ButtonTitleOfKeyBoard()["Row4OfSpendedItem"],
                                            ButtonTitleOfKeyBoard()["Row5OfSpendedItem"]])
            self.addSubview(view)
        }else{
        let view = CreateKeyboard.createKeyboard(withArrayOfButtonRow:[ButtonTitleOfKeyBoard()["Row1OfIncomeItem"],
                                           ButtonTitleOfKeyBoard()["Row2OfIncomeItem"]])
            
            self.addSubview(view)
        }
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
}

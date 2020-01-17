//
//  CustomKeyboardView.swift
//  Accounting note
//
//  Created by tautau on 2018/9/22.
//  Copyright © 2018年 tautau. All rights reserved.
//

import UIKit

protocol CustomKeyboardDelegate {
    func buttonTapped(text:String)
}
struct ButtonTitleOfKeyBoard {
    var titles = ["Row1OfSpendedItem":["Food&Drink", "Insurance", "Car"],
                  "Row2OfSpendedItem":["Trasportation", "Clothes", "Utilities"],
                  "Row3OfSpendedItem":["Entertainment", "BetterHalf", "Phone"],
                  "Row4OfSpendedItem":["Beauty&Hair", "Learning", "Social"],
                  "Row5OfSpendedItem":["DailySupplies", "Tax", "HealthCare"],
                  "Row1OfIncomeItem":["Salary", "Bonus", "Investment"],
                  "Row2OfIncomeItem":["SideLine", "", ""]
    ]
    
    subscript(key:String) -> Array<String>{
        if let titles = titles[key]{
            return titles
        }else{
            return []
        }
    }
}
class CreateKeyboard{
    static var delegate:CustomKeyboardDelegate?
    
    private static func createButtonWithTitle(title: String)->UIButton {
        let button = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 50))
        button.backgroundColor = .green
        button.setTitle(title, for: .normal)
        button.sizeToFit()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(white: 1.0, alpha: 1.0)
        button.setTitleColor(UIColor.darkGray, for: .normal)
        button.addTarget(self, action: #selector(typeButtonTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(typeButtonTouchDown), for: .touchDown)
        return button
    }
    
    @objc static func typeButtonTouchDown(_ sender: UIButton) {
        guard let _ = sender.titleLabel?.text else{return}
        sender.borderWidth = 2
        sender.borderColor = UIColor.blue
    }
    
    @objc static func typeButtonTapped(_ sender: UIButton) {
        guard let _ = sender.titleLabel?.text else{return}
        sender.borderColor = UIColor.clear
        if let label = sender.titleLabel?.text {
            delegate?.buttonTapped(text: label)
        }
    }
    
    private static func addIndividualButtonConstraints(buttons: [UIButton], mainView: UIView){
        for (index, button) in buttons.enumerated(){
            let topConstraint = NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: mainView, attribute: .top, multiplier: 1.0, constant: 1)
            let bottomConstraint = NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: mainView, attribute: .bottom, multiplier: 1.0, constant: -1)
            
            var rightConstraint : NSLayoutConstraint!
            if index == buttons.count - 1 {
                rightConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: mainView, attribute: .right, multiplier: 1.0, constant: -1)
            }else{
                let nextButton = buttons[index+1]
                rightConstraint = NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: nextButton, attribute: .left, multiplier: 1.0, constant: -1)
            }
            
            
            var leftConstraint : NSLayoutConstraint!
            if index == 0 {
                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: mainView, attribute: .left, multiplier: 1.0, constant: 1)
            }else{
                let prevtButton = buttons[index-1]
                leftConstraint = NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: prevtButton, attribute: .right, multiplier: 1.0, constant: 1)
                let firstButton = buttons[0]
                let widthConstraint = NSLayoutConstraint(item: firstButton, attribute: .width, relatedBy: .equal, toItem: button, attribute: .width, multiplier: 1.0, constant: 0)
                mainView.addConstraint(widthConstraint)
            }
            
            mainView.addConstraints([topConstraint, bottomConstraint, rightConstraint, leftConstraint])
        }
    }
    
    
    static func createRowOfButtons(buttonTitles: [String]) -> UIView {
        var buttons = [UIButton]()
        let keyboardRowView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        for buttonTitle in buttonTitles{
            let button = createButtonWithTitle(title: buttonTitle as String)
            buttons.append(button)
            keyboardRowView.addSubview(button)
        }
        addIndividualButtonConstraints(buttons: buttons, mainView: keyboardRowView)
        return keyboardRowView
    }
    
    static func addConstraintsToInputView(inputView: UIView, rowViews: [UIView]){
        for (index, rowView) in rowViews.enumerated() {
            let rightSideConstraint = NSLayoutConstraint(item: rowView, attribute: .right, relatedBy: .equal, toItem: inputView, attribute: .right, multiplier: 1.0, constant: -1)
            let leftConstraint = NSLayoutConstraint(item: rowView, attribute: .left, relatedBy: .equal, toItem: inputView, attribute: .left, multiplier: 1.0, constant: 1)
            inputView.addConstraints([leftConstraint, rightSideConstraint])
            
            var topConstraint: NSLayoutConstraint
            if index == 0 {
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .top, relatedBy: .equal, toItem: inputView, attribute: .top, multiplier: 1.0, constant: 0)
            }else{
                let prevRow = rowViews[index-1]
                topConstraint = NSLayoutConstraint(item: rowView, attribute: .top, relatedBy: .equal, toItem: prevRow, attribute: .bottom, multiplier: 1.0, constant: 0)
                let firstRow = rowViews[0]
                let heightConstraint = NSLayoutConstraint(item: firstRow, attribute: .height, relatedBy: .equal, toItem: rowView, attribute: .height, multiplier: 1.0, constant: 0)
                inputView.addConstraint(heightConstraint)
            }
            inputView.addConstraint(topConstraint)
            
            var bottomConstraint: NSLayoutConstraint
            if index == rowViews.count - 1 {
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .bottom, relatedBy: .equal, toItem: inputView, attribute: .bottom, multiplier: 1.0, constant: 0)
            }else{
                let nextRow = rowViews[index+1]
                bottomConstraint = NSLayoutConstraint(item: rowView, attribute: .bottom, relatedBy: .equal, toItem: nextRow, attribute: .top, multiplier: 1.0, constant: 0)
            }
            inputView.addConstraint(bottomConstraint)
        }
        
    }
    static func createKeyboard(withArrayOfButtonRow:[Array<String>])->UIView{
        let keyboardView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 200))
        for rowOfButtonTitles in withArrayOfButtonRow{
            let row = CreateKeyboard.createRowOfButtons(buttonTitles: rowOfButtonTitles)
            row.translatesAutoresizingMaskIntoConstraints = false
            keyboardView.addSubview(row)
        }
        CreateKeyboard.addConstraintsToInputView(inputView: keyboardView, rowViews: keyboardView.subviews)
        return keyboardView
    }
    
}

//
//  AddNewItemController.swift
//  Accounting note
//
//  Created by tautau on 2018/8/22.
//  Copyright © 2018年 tautau. All rights reserved.
//

import UIKit
import RealmSwift
import DatePickerDialog

class UpdateItemViewController: UIInputViewController,UITextFieldDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CustomKeyboardDelegate{
    
    @IBOutlet var itemAmountField: UITextField!
    @IBOutlet var itemTypeTextField: UITextField!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var DateLabel: UILabel!
    @IBOutlet var noteTextView: UITextView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var segmentedControl: UISegmentedControl!
    
    let userPickerView = UIImagePickerController()
    var dateFormatter = DateFormatter()
    let realm = try! Realm()
    var editItem:Item?
    var dateString:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "TestView", bundle: nil)
        guard let CustomKeyboardView = nib.instantiate(withOwner: self, options: nil).last as? UIView else{fatalError("Can not get custom ketboard")}
        CreateKeyboard.delegate = self
        itemTypeTextField.inputView = CustomKeyboardView
        itemAmountField.keyboardType = UIKeyboardType.decimalPad
        
        itemTypeTextField.delegate = self
        itemAmountField.delegate = self
        noteTextView.delegate = self
        
        userPickerView.delegate = self
        userPickerView.sourceType = .photoLibrary
        userPickerView.allowsEditing = false
        
        
        dateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            formatter.locale = Locale(identifier: "en_US")
            formatter.timeStyle = .none
            formatter.dateStyle = .medium
            return formatter
        }()
        
        
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(myImage_Touch)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        segmentedControl.addTarget(self, action: #selector(segmentedControlSwitch), for: .valueChanged)
        
        if let date = dateString
        {
            DateLabel.text = date
            guard let item = editItem else{return}
            segmentedControl.selectedSegmentIndex = item.incomeOrCost
            itemAmountField.text = item.amount
            itemTypeTextField.text = item.category
            if item.note != "Write some note..."
            {
                noteTextView.text = item.note
                noteTextView.textColor = UIColor.black
            }
            imageView.image = UIImage(data: item.image)
        }else{
            DateLabel.isUserInteractionEnabled = true
            DateLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dateLabel_Touch)))
            DateLabel.text = dateFormatter.string(from: Date())
        }
    }
    
    @objc func segmentedControlSwitch()
    {
        let name = Notification.Name("segmentControlValueChanged")
        NotificationCenter.default.post(name:name , object: nil, userInfo: ["segmentControlValue":segmentedControl.selectedSegmentIndex])
    }
    
    // MARK: - UI Action
    @IBAction func barSaveButtonTapped(_ sender: UIBarButtonItem) {
        
        // Check textField is empty
        if itemAmountField.text!.isEmpty{
            alertPop(withTitle: "Item cost is empty", message: "Please fill in cost")
            return
        }
        if itemTypeTextField.text!.isEmpty{
            alertPop(withTitle: "Item type is empty", message: "Please fill in type")
            return
        }
        guard let imageData = UIImageJPEGRepresentation(imageView.image!, 0.5) else{fatalError("Image converted to JPEG failed")}
        
        // Create new Item
        let itemAttributes = [segmentedControl.selectedSegmentIndex,itemTypeTextField.text!,itemAmountField.text!,noteTextView.text!,imageData
            ] as [Any]
        let newItem = Item(value: itemAttributes )
        guard let dateArray = DateLabel.text?.split(separator: ",")[0].split(separator: " ")else{fatalError("Get date error")}
        
        //realm add/modify newItem
        do{
            let monthlyInfo = realm.objects(MonthlyInfo.self).filter("month CONTAINS[cd] %@",String(dateArray[0]))
            if monthlyInfo.isEmpty{
                let newMonthlyInfo = MonthlyInfo(value: [String(dateArray[0]),0,0,0])
                newMonthlyInfo.days.append(DayInfo(value: [String(dateArray[1])]))
                print(newMonthlyInfo)
                try realm.write {realm.add(newMonthlyInfo)}
            }
            
            let dayInfo = monthlyInfo.first!.days.filter("day CONTAINS[cd] %@",String(dateArray[1]))
            
            try realm.write {
                //remove old item
                if let oldItem = editItem{
                    if oldItem.incomeOrCost == 0{
                        dayInfo[0].totalSpend -= Int(oldItem.amount)!
                        monthlyInfo[0].totalSpend -= Int(oldItem.amount)!
                    }else{
                        dayInfo[0].totalIncome -= Int(oldItem.amount)!
                        monthlyInfo[0].totalIncome -= Int(oldItem.amount)!
                    }
                    realm.delete(oldItem)
                }
                //append new item
                dayInfo[0].items.append(newItem)
                if newItem.incomeOrCost == 0{
                    dayInfo[0].totalSpend += Int(newItem.amount)!
                    monthlyInfo[0].totalSpend += Int(newItem.amount)!
                }else{
                    dayInfo[0].totalIncome += Int(newItem.amount)!
                    monthlyInfo[0].totalIncome += Int(newItem.amount)!
                }
                monthlyInfo[0].totalBalance = monthlyInfo[0].totalIncome - monthlyInfo[0].totalSpend
                dayInfo[0].totalBalance = dayInfo[0].totalIncome - dayInfo[0].totalSpend
            }
            
        }catch{
            print("Save item error,\(error)")
        }
        
        _ = [self.navigationController?.popViewController(animated: true)]
    }
    
    // MARK: - Alert Function
    func alertPop(withTitle title :String,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
    
    // MARK: - Image view tapped gesture
    @objc func myImage_Touch(){
        present(userPickerView, animated: true)
    }
    
    // MARK: - Date label tapped gesture
    @objc func dateLabel_Touch(){
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        guard let defaultDate = dateFormatter.date(from: "Jan 01, \(year)")else {fatalError("Set default date error")}
        guard let maximumDate = dateFormatter.date(from: "Dec 31, \(year)")else {fatalError("Set default date error")}
        
        DatePickerDialog().show("DatePicker",
                                doneButtonTitle: "Done",
                                cancelButtonTitle: "Cancel",
                                minimumDate: defaultDate,
                                maximumDate: maximumDate,
                                datePickerMode: .date)
        {(date)  in
            let date = self.dateFormatter.string(from: date!)
            self.DateLabel.text = date
        }
    }
    
    // MARK: - Text field delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    // MARK: - Image picker delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let userPickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = userPickedImage
        }
        userPickerView.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Text View delegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        let range = NSMakeRange(textView.text.count - 1, 0)
        noteTextView.scrollRangeToVisible(range)
        if noteTextView.textColor == UIColor.white {
            noteTextView.text = nil
            noteTextView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if noteTextView.text.isEmpty {
            noteTextView.text = "Write some note..."
            noteTextView.textColor = UIColor.white
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    // MARK: - Keyboard notificaton function
    @objc func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo
        let kbSize = (info![UIKeyboardFrameEndUserInfoKey]as! NSValue).cgRectValue
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: kbSize.height, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        guard let firstResponder = view.currentFirstResponder() as? UIView else{return}
        var aRect = self.view.frame
        aRect.size.height -= kbSize.height
        if !aRect.contains(firstResponder.frame){
            aRect.size.height += firstResponder.frame.height
            scrollView .scrollRectToVisible(aRect, animated: true)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        let contentInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }
    func buttonTapped(text: String) {
        let currentTextLong = textDocumentProxy.documentContextBeforeInput?.count ?? 1
        for _ in 1...currentTextLong{textDocumentProxy.deleteBackward()}
        textDocumentProxy.insertText(text)
    }
}

extension UIView {
    func currentFirstResponder() -> UIResponder? {
        if self.isFirstResponder {
            return self
        }
        
        for view in self.subviews {
            if let responder = view.currentFirstResponder() {
                return responder
            }
        }
        
        return nil
    }
}



//
//  HomePageViewController.swift
//  Accounting note
//
//  Created by tautau on 2018/8/30.
//  Copyright © 2018年 tautau. All rights reserved.
//

import UIKit
import SwiftyButton

class HomePageViewController: UIViewController {
    @IBOutlet var monthButton: UIButton!
    var myScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func monthButtonTapped(_ sender: UIButton) {
        sender.layer.shadowColor = UIColor.gray.cgColor
        performSegue(withIdentifier: "goToDateList", sender: sender)
    }
    
    @IBAction func mothButtonTouchDown(_ sender: UIButton) {
        sender.layer.shadowColor = UIColor.white.cgColor
    }
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToAddNewItem", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DateViewController{
            if let button = sender as? UIButton{
            vc.selectedMonth = button.titleLabel?.text!
            }
        }
    }

}

extension UIView {
    // interface Builder property
    @IBInspectable var masksToBounds: Bool{
        get {
            return layer.masksToBounds
        }
        set {
            layer.masksToBounds = newValue
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat{
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable var shadowOpacity: Float{
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable var shadowWidthOffset: CGFloat{
        get {
            return layer.shadowOffset.width
        }
        set {
            layer.shadowOffset.width = newValue
        }
    }
    
    @IBInspectable var shadowHeightOffset: CGFloat{
        get {
            return layer.shadowOffset.height
        }
        set {
            layer.shadowOffset.height = newValue
        }
    }
    
    @IBInspectable var shadowColor: UIColor?  {
        get {
            return UIColor(cgColor: layer.shadowColor!)
        }
        set {
            layer.shadowColor = newValue?.cgColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }}
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }}
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

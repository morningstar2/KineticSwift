//
//  Utils.swift
//  dataconnect
//
//  Created by hienng on 9/25/17.
//  Copyright © 2017 cisco. All rights reserved.
//

import UIKit

//*****************************************************************
// MARK: - Extensions
//*****************************************************************

public extension UIColor {
    public class func ciscoStatusBlue()->UIColor {
        struct C {
            static var c : UIColor = UIColor(red: 100/255, green: 187/255, blue: 227/255, alpha: 1.0)
        }
        return C.c
    }
    
    public class func ciscoLightBlue()->UIColor {
        struct C {
            static var c : UIColor = UIColor(red: 77/255, green: 181/255, blue: 217/255, alpha: 1)
        }
        return C.c
    }
    
    public class func ciscoMediumGrey()->UIColor {
        struct C {
            static var c : UIColor = UIColor(red: 158/255, green: 158/255, blue: 163/255, alpha: 1)
        }
        return C.c
    }
}

@IBDesignable
class CustomButton: UIButton {
    @IBInspectable var cornerRadiusValue: CGFloat = 5.0 {
        didSet {
            setUpView()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpView()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setUpView()
    }
    
    func setUpView() {
        self.layer.cornerRadius = self.cornerRadiusValue
        self.clipsToBounds = true
    }
}

//*****************************************************************
// MARK: - Helper Functions
//*****************************************************************

public func delay(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}

public func saveToStore( for key: String, with value: Any){
    let defaults = UserDefaults.standard
    defaults.set(value, forKey:key)
    defaults.synchronize()
}

public func retrieveFromStore(for key: String) -> [String: AnyObject]{
    let results = UserDefaults.standard.object(forKey: key) as? [String: AnyObject] ?? [String: AnyObject]()
    return results
}

public func getApiKeyFromStore(for key: String)-> String {
    return UserDefaults.standard.object(forKey: key) as? String ?? String()
}

public func getSelectedOrgFromStore(for key: String) -> Int {
    return UserDefaults.standard.object(forKey: key) as? Int ?? Int()
}

public func getIdFromStore(for key: String) -> Int {
    return UserDefaults.standard.object(forKey: key) as? Int ?? Int()
}

public func getFromStore(for key: String) -> String {
    return UserDefaults.standard.object(forKey: key) as? String ?? String()
}






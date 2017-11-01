//
//  ProfileViewController.swift
//  dataconnect
//
//  Created by hienng on 10/13/17.
//  Copyright © 2017 cisco. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import NVActivityIndicatorView
import SwiftValidator



class ProfileViewController: UIViewController, UITextFieldDelegate, NVActivityIndicatorViewable, ValidationDelegate {

    @IBOutlet weak var backBarButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: CustomButton!
    @IBOutlet weak var profileName: SkyFloatingLabelTextField!
    @IBOutlet weak var server: SkyFloatingLabelTextField!
    @IBOutlet weak var username: SkyFloatingLabelTextField!
    @IBOutlet weak var password: SkyFloatingLabelTextField!
    
    var selectedProfile: Profile?
    let activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 100, y: 100, width: 150, height: 150), type: .ballSpinFadeLoader, color: UIColor.white, padding: CGFloat(0))
    
    let validator = Validator()
    
    //var prompt = SwiftPromptsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        validator.registerField(profileName, rules: [RequiredRule(), MinLengthRule(length: 3), MaxLengthRule(length: 26)])
        validator.registerField(server, rules: [RequiredRule()])
        validator.registerField(username, rules: [RequiredRule(), EmailRule()])
        validator.registerField(password, rules: [RequiredRule(), MinLengthRule(length: 3), MaxLengthRule(length: 16)])
        
        profileName.delegate = self
        server.delegate = self
        username.delegate = self
        password.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let profile = selectedProfile {
            print("selectedProfile = \(profile)")
            profileName.text = profile.name
            server.text = profile.server
            username.text = profile.username
            password.text = profile.password
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.databaseStatusChanged(_:)), name: NSNotification.Name(rawValue: KINETIC_DB_STATUS_CHANGED), object: nil)
        
        self.navigationController?.navigationBar.topItem?.title = "Profile"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.selectedProfile = nil
    }
    
    @objc func databaseStatusChanged (_ notification: NSNotification){
        guard let userInfo = notification.userInfo, let message  = userInfo["message"] as? String
        else {
            debugPrint("No userInfo.message found in notification")
            return
        }
        
        let size = CGSize(width: 25, height: 25)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            self.startAnimating(size, message: message, type: NVActivityIndicatorType(rawValue: 23))
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            self.stopAnimating()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func backAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveProfileAction(_ sender: Any) {
        
        validator.validate(self)
    }
    
    func validationSuccessful() {
        print("Validation Success!")
        let size = CGSize(width: 25, height: 25)
        
//        guard selectedProfile != nil else {
//            print("has profile")
//            return
//        }
        if let profile = selectedProfile {
            print(profile)
            
            let p = Profile(id: profile.id!, name: profileName.text!, server: server.text!, username: username.text!, password: password.text!)
            
            if let b = KineticDB.instance.updateProfile(pid: profile.id!, newProfile: p){

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                    self.startAnimating(size, message: "Profile Updated.", type: NVActivityIndicatorType(rawValue: 23))
                }

                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                    self.stopAnimating()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        else{
            //New Profile
            if let id = KineticDB.instance.addProfile(pname: profileName.text!, pserver: server.text!, pusername: username.text!, ppassword: password.text!){
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                    self.startAnimating(size, message: "Profile Saved.", type: NVActivityIndicatorType(rawValue: 23))
                }
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                    self.stopAnimating()
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
   
    
    func validationFailed(_ errors:[(Validatable, ValidationError)]) {
        print("Validation FAILED!")
        // turn the fields to red
        for (field, error) in errors {
            if let field = field as? SkyFloatingLabelTextField {
                field.selectedLineColor = UIColor.red
                //field.layer.borderWidth = 1.0
                field.errorMessage = error.errorMessage
            }
        }
    }
    
    /// Implementing a method on the UITextFieldDelegate protocol. This will notify us when something has changed on the textfield
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let textField = textField as? SkyFloatingLabelTextField {
            validator.validateField(textField){ error in
                if error == nil {
                        // Field validation was successful
                        textField.selectedLineColor = UIColor.ciscoStatusBlue()
                        textField.errorMessage = ""
                } else {
                        // Validation error occurred
                        textField.selectedLineColor = UIColor.red
                        textField.errorMessage = error?.errorMessage
                }
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ProfileViewController: DatabaseStatusListener {
    
    func errorStatusChanged(status: NSError){
        print("in profile view errorStatusChanged")
    }
}

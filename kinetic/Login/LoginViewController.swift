//
//  LoginViewController.swift
//  dataconnect
//
//  Created by hienng on 9/28/17.
//  Copyright © 2017 cisco. All rights reserved.
//

import UIKit
import ReachabilitySwift
import SkyFloatingLabelTextField
import AFNetworking
import NVActivityIndicatorView
import LocalAuthentication
import ESTabBarController_swift

class LoginViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate,  NVActivityIndicatorViewable, UIAlertViewDelegate {

    @IBOutlet weak var profileTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var createProfileButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var backgroundView: UIView!
    
    var pickerView = UIPickerView()
    var savedProfiles = [Profile]()
    var selectedProfile: Profile?
    var isLoggedIn: Bool?
    
    let activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 100, y: 100, width: 150, height: 150), type: .ballSpinFadeLoader, color: UIColor.white, padding: CGFloat(0))
    
    init(isLoggedIn: Bool, selectedProfile: Profile) {
        self.isLoggedIn = isLoggedIn
        self.selectedProfile = selectedProfile
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated:Bool){
        super.viewWillAppear(animated)
        signinButton.backgroundColor = UIColor.ciscoMediumGrey()
        ReachabilityManager.shared.startMonitoring()
        ReachabilityManager.shared.addListener(listener: self)
        
        //Load the saved profiles
        savedProfiles = loadSavedProfiles()
        isLoggedIn = false
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ReachabilityManager.shared.stopMonitoring()
        ReachabilityManager.shared.removeListener(listener: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        profileTextField.inputView = pickerView
        profileTextField.delegate = self
        
//        //Load the saved profiles
//        savedProfiles = loadSavedProfiles()
//        isLoggedIn = false
        
        //Add gesture recognizer to handle picker tap
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handlePickerTap(_:)))
        tapGesture.delegate = self
        pickerView.addGestureRecognizer(tapGesture)
        
        //Add gesture recognizer to handle background tap
        let backgroundGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap(_:)))
        backgroundGesture.delegate = self
        backgroundView.addGestureRecognizer(backgroundGesture)
    }
   
    @objc func handleBackgroundTap(_ recognizer: UITapGestureRecognizer){
        if !pickerView.isHidden {
            pickerView.removeFromSuperview()
            profileTextField.resignFirstResponder()
        }
        else{
            self.view.addSubview(pickerView)
        }
    }
    
    @objc func handlePickerTap(_ recognizer: UITapGestureRecognizer) {
        let pickerView = recognizer.view as! UIPickerView
        let row = pickerView.selectedRow(inComponent: 0)
            
        if row == 0 {
            self.pickerView(self.pickerView, didSelectRow: 0, inComponent: 0)
        }
        profileTextField.text = savedProfiles[row].name
        
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
       
        print("editing")
        if savedProfiles.count == 0 {
            pickerView.removeFromSuperview()
            profileTextField.resignFirstResponder()
            self.performSegue(withIdentifier: "ADD_NEW_PROFILE_SEGUE", sender: self)
        }
//        if textField == profileTextField {
//            self.pickerView.selectRow(0, inComponent: 0, animated: true)
//            //self.pickerView(self.pickerView, didSelectRow: 0, inComponent: 0)
//        }
  }
   
    @IBAction func createProfileTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "ADD_NEW_PROFILE_SEGUE", sender: self)
    }
    
    @IBAction func signInTapped(_ sender: Any) {
     
        if (profileTextField.text?.isEmpty)! {
            errorLabel.text = "Please select a profile"
            errorLabel.isHidden = false
        }
        else{
            errorLabel.text = ""
            errorLabel.isHidden = true
            let size = CGSize(width: 50, height: 50)
            
            startAnimating(size, message: MESSAGES.AUTHENTICATING, type: NVActivityIndicatorType(rawValue: 23))
            login2(with: selectedProfile!)
            
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let navController = storyboard.instantiateViewController(withIdentifier: "OrganizationController")
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.window?.rootViewController = navController
        }
    }
    
    func loadSavedProfiles() -> [Profile]{
        let profiles = KineticDB.instance.getProfiles()
        print(profiles)
        return profiles
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return savedProfiles.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return savedProfiles[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedProfile = savedProfiles[row]
        profileTextField.text = savedProfiles[row].name
        profileTextField.resignFirstResponder()
        
        errorLabel.text = ""
        errorLabel.isHidden = true
        signinButton.backgroundColor = UIColor.ciscoStatusBlue()
        
    }
    
    func login2(with selectedProfile: Profile){
        
    
        let url = NSURL(string: "\(HTTPS + selectedProfile.server + SERVICE_URL.SESSIONS)")
        var request = URLRequest(url: url! as URL)
        request.httpMethod = POST
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        //request.addValue(apiKey!, forHTTPHeaderField: DATACONNECT_API_KEY)
        
        let params: Dictionary<String,AnyObject> = ["email": selectedProfile.username as AnyObject,
                                                    "password": selectedProfile.password as AnyObject]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        let defaultSession = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main)
        
        
        let task: URLSessionDataTask = defaultSession.dataTask(
            with: request,
            completionHandler:{ (data, response, error) in
                if let data = data, let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        if let responseObject = try! JSONSerialization.jsonObject(
                            with: data, options:[]) as? NSDictionary {
                           
                            print(responseObject)
                            if let api_key = responseObject[DATACONNECT_API_KEY] as! String? {
                                saveToStore(for: DATACONNECT_API_KEY, with: api_key)
                                saveToStore(for: "isLoggedIn", with: true)
                                saveToStore(for:"selectedProfileServer", with:selectedProfile.server)
                                
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                                    self.stopAnimating()
                                    
                                    //Perform segue to organizations
                                    self.performSegue(withIdentifier: SEGUE.LOGIN, sender: self)
                                }
                            }
                            else {
                                saveToStore(for: "isLoggedIn", with: false)
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                                    NVActivityIndicatorPresenter.sharedInstance.setMessage(MESSAGES.NO_AUTHENTICATION_TOKEN)
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                                    self.stopAnimating()
                                }
                            }
                        }
                        else{
                            debugPrint("can't parse data")
                        }
                    }
                    else if response.statusCode == 401{
                        debugPrint("response.statusCode = \(response.statusCode)")
                        saveToStore(for: "isLoggedIn", with: false)
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                            NVActivityIndicatorPresenter.sharedInstance.setMessage(MESSAGES.INVALID_USERNAME_PASSWORD)
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                            self.stopAnimating()
                            self.editProfile()
                        }
                    }
                }
                if let error = error {
                    debugPrint("DataTask error: " + error.localizedDescription + "\n")
                }
                
        })
        task.resume()
    }
    
    func login( with selectedProfile:Profile){
        let url = HTTPS + selectedProfile.server + SERVICE_URL.SESSIONS
        
        let postParams: Dictionary? = [
            "email": selectedProfile.username,
            "password": selectedProfile.password
        ]
        
        let manager = AFHTTPSessionManager()
        let serializedRequest = AFJSONRequestSerializer()
        manager.requestSerializer = serializedRequest
        
        let serializedResponse = AFJSONResponseSerializer()
        manager.responseSerializer = serializedResponse
        
        manager.post(url, parameters: postParams, progress: nil,
         success: { (task: URLSessionDataTask, responseObject: Any?) in
            if (responseObject as? [String: AnyObject]) != nil {
                print("responseObject \(String(describing: responseObject))")
                
                let responseData = responseObject as! NSDictionary
                
                if let api_key = responseData[DATACONNECT_API_KEY] as! String? {
                    saveToStore(for: DATACONNECT_API_KEY, with: api_key)
                    saveToStore(for: "isLoggedIn", with: true)
                    saveToStore(for:"selectedProfileServer", with:selectedProfile.server)
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                        self.stopAnimating()
                        
                        //Perform segue to organizations
                        self.performSegue(withIdentifier: SEGUE.LOGIN, sender: self)
                    }
                }
                else {
                    debugPrint("No API Key returned")
                    saveToStore(for: "isLoggedIn", with: false)
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                        NVActivityIndicatorPresenter.sharedInstance.setMessage(MESSAGES.LOGIN_FAILED)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                        self.stopAnimating()
                    }
                }
                
            }
        }) { (task: URLSessionDataTask?, error: Error) in
            debugPrint("Post failed with error \(error)")
            saveToStore(for: "isLoggedIn", with: false)
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                NVActivityIndicatorPresenter.sharedInstance.setMessage(MESSAGES.LOGIN_FAILED)
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                self.stopAnimating()
                self.editProfile()
            }
        }
    }
    
    private func editProfile(){
       // let destinationVC = segue.destination as! UINavigationController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navController = storyboard.instantiateViewController(withIdentifier: "ProfilesNavigationController") as! UINavigationController
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        if let profile = selectedProfile {
            vc.selectedProfile = profile
        }
        navController.pushViewController(vc, animated: true)
        self.present(navController, animated: true, completion: nil)
    }

    //func retrieveProfileFromStore
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LOGIN_SEGUE" {
            let destinationVC = segue.destination as! MainNavigationViewController
            if let targetVC = destinationVC.topViewController as? OrganizationsViewController{
                targetVC.selectedProfile = selectedProfile!
            }
        }
        else if segue.identifier == "ADD_NEW_PROFILE_SEGUE" {
            let destinationVC = segue.destination as! UINavigationController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            vc.selectedProfile = nil
            destinationVC.pushViewController(vc, animated: true)
        }
        
    }
}

extension LoginViewController: NetworkStatusListener {
    
    func networkStatusDidChange(status: Reachability.NetworkStatus) {
        
        let size = CGSize(width: 50, height: 50)
        
        switch status{
        case .notReachable:
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                self.startAnimating(size, message: "Network is unreachable.  Please turn off airplane mode.", type: NVActivityIndicatorType(rawValue: 14))
            }
            debugPrint("ViewController: Network became unreachable")
        case .reachableViaWiFi:
            debugPrint("ViewController: Network reachable through WiFi")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                NVActivityIndicatorPresenter.sharedInstance.setMessage("Network is reachable through WiFi")
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                self.stopAnimating()
            }
            
        case .reachableViaWWAN:
            debugPrint("ViewController: Network reachable through Cellular Data")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                NVActivityIndicatorPresenter.sharedInstance.setMessage("Network is reachable through Cellular Data")
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
                self.stopAnimating()
            }
        }
        
    }
}


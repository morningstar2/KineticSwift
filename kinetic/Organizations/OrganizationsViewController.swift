//
//  OrganizationsViewController.swift
//  dataconnect
//
//  Created by hienng on 10/3/17.
//  Copyright © 2017 cisco. All rights reserved.
//

import UIKit
import AFNetworking

class OrganizationsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedProfile = Profile(id: 0)
    var organizationsArray: [String: Array<Any>] = [:]
    var orgSections = [ORGANIZATIONS.OWNER, ORGANIZATIONS.MEMBERS]
    
    var apiKey: String?
     
    var refreshControl = UIRefreshControl()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return orgSections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rowCount = organizationsArray[orgSections[section]]?.count{
            return rowCount
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return CGFloat.leastNormalMagnitude
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrgCell") as! OrganizationCell
        
        var orgName: String = ""
        
        if organizationsArray[orgSections[indexPath.section]] != nil {
            let sectionDataArray = organizationsArray[orgSections[indexPath.section]]
            let cellData = sectionDataArray![indexPath.row]  as? [String: Any]
            orgName = (cellData!["name"] as? String)!
            
            cell.orgLabel?.text = orgName
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return orgSections[section]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOrg = organizationsArray[orgSections[indexPath.section]]![indexPath.row] as? [String: Any]
        
        //Store the selectedOrg
        saveToStore(for: SELECTED_ORG_ID, with: selectedOrg!["id"] ?? -1)
        self.performSegue(withIdentifier: "SHOW_GATEWAYS", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Get the keys from dataStore
        apiKey = getApiKeyFromStore(for: DATACONNECT_API_KEY)
        debugPrint("\(String(describing: apiKey))")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
     
        refreshControl.addTarget(
            self,
            action: #selector(refreshControlAction(refreshControl:)),
            for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        refreshControlAction(refreshControl: refreshControl)
        getOrganizations()
    
        setupNavigationBarItems()
        
    }
    
    private func setupNavigationBarItems(){
        
        let titleImageView = UIImageView(image: #imageLiteral(resourceName: "cisco_logo_blue"))
        titleImageView.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        titleImageView.contentMode = .scaleAspectFit
        navigationItem.titleView = titleImageView
        
        
        let logoutButton = UIButton(type: .system)
        logoutButton.setImage(#imageLiteral(resourceName: "logout").withRenderingMode(UIImageRenderingMode.alwaysOriginal), for: .normal)
        logoutButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        logoutButton.contentMode = .scaleAspectFit
        logoutButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(logoutTapped)))
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView:logoutButton)
        
        let profilesButton = UIButton(type: .system)
        profilesButton.setImage(#imageLiteral(resourceName: "profiles").withRenderingMode(UIImageRenderingMode.alwaysOriginal), for: .normal)
        profilesButton.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        profilesButton.contentMode = .scaleAspectFit
        profilesButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(profilesTapped)))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profilesButton)
        
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
    }
    
    // Private action
    @objc fileprivate func profilesTapped() {        
        self.performSegue(withIdentifier: "SHOW_PROFILES", sender: self)
    }
    
    @objc fileprivate func logoutTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func refreshControlAction(refreshControl: UIRefreshControl) {
        self.refreshControl = refreshControl
        getOrganizations()
    }
    
    func getOrganizations() {
        
        let api_key = getApiKeyFromStore(for: DATACONNECT_API_KEY)
        
        let url = NSURL(string: "\(HTTPS + selectedProfile.server + SERVICE_URL.ORGANIZATIONS)")
        var request = URLRequest(url: url! as URL)
        request.httpMethod = GET
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(api_key, forHTTPHeaderField: DATACONNECT_API_KEY)
        
        let defaultSession = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main)
        
        let task: URLSessionDataTask = defaultSession.dataTask(
            with: request,
            completionHandler:{ (data, response, error) in
                if let data = data, let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        if let responseArray = try! JSONSerialization.jsonObject(
                            with: data, options:[]) as? NSDictionary {
 
                            let members = responseArray["member_of_organizations"] as? [Dictionary<String, Any>]
                            let owners = responseArray["owner_of_organizations"] as? [Dictionary<String, Any>]
                            
                            self.organizationsArray[self.orgSections[0]] = owners
                            self.organizationsArray[self.orgSections[1]] = members
                           
                            self.tableView.reloadData()
                            self.refreshControl.endRefreshing()
                        }
                        else{
                            debugPrint("can't parse data")
                        }
                    }
                }
                if let error = error {
                   debugPrint("DataTask error: " + error.localizedDescription + "\n")
                }
        })
        task.resume()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

//
//  GatewaysViewController.swift
//  dataconnect
//
//  Created by hienng on 10/16/17.
//  Copyright © 2017 cisco. All rights reserved.
//

import UIKit


class GatewaysViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var apiKey: String?
    var refreshControl = UIRefreshControl()
    var gatewaysArray: [Dictionary<String, Any>]?
    var selectedOrgId: Int?
    var segmentedController: UISegmentedControl!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let rowCount = gatewaysArray?.count {
            return rowCount
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GatewayCell") as! GatewayTableViewCell
        
        let cellData = gatewaysArray![indexPath.row]
        
        print(cellData)
        
        if let name = cellData["name"] as? String {
            cell.gatewayName?.text = name
        }
        else{
            cell.gatewayName?.text = "Name your Gateway"
        }
        
        cell.serialNumber?.text = cellData["uuid"] as? String
        cell.model?.text = cellData["model"] as? String
        cell.swVersion?.text = cellData["sw_version"] as? String
        
        if let status = cellData["status"] as? String {
           if status == "Healthy"{
                cell.statusImage?.image = UIImage(named: "Up")
                cell.gatewayHealth?.text =  cellData["status"] as? String
            }
            else if status == "Down"{
                cell.statusImage?.image = UIImage(named: "Down")
                cell.gatewayHealth?.text =  cellData["status"] as? String
            }
            else{
                cell.statusImage?.image = UIImage(named: "Inactive")
                cell.gatewayHealth?.text =  cellData["status"] as? String
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedGateway = gatewaysArray![indexPath.row] as [String: Any]
   
        //Store the selectedOrg
        saveToStore(for: SELECTED_GATEWAY_ID, with: selectedGateway["id"] ?? -1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getGateways()
        setupNavigationItems()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let items = ["List", "Maps"]
//        segmentedController = UISegmentedControl(items: items)
//        segmentedController.selectedSegmentIndex = 0
//        //self.navigationController?.topViewController.titleView = segmentedController
//        self.tabBarController?.navigationItem.titleView = segmentedController
//        //self.title = "test"
        
        //self.tabBarController?.navigationItem.title = "Gateways"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl.addTarget(
            self,
            action: #selector(refreshControlAction(refreshControl:)),
            for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        refreshControlAction(refreshControl: refreshControl)
        
        setupNavigationItems()
        
        // Do any additional setup after loading the view.
        
//        let titleImageView = UIImageView(image: #imageLiteral(resourceName: "cisco_logo_blue"))
//        titleImageView.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
//        titleImageView.contentMode = .scaleAspectFit
//        self.tabBarController?.navigationItem.titleView = titleImageView
    }
    
    func setupNavigationItems(){
//        let items = ["List", "Maps"]
//        segmentedController = UISegmentedControl(items: items)
//        segmentedController.selectedSegmentIndex = 0
//        //self.navigationController?.topViewController.titleView = segmentedController
//        self.tabBarController?.navigationItem.titleView = segmentedController
        
        let label = UILabel()
        label.text = "Gateways"
        self.tabBarController?.navigationItem.titleView = label
        
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func refreshControlAction(refreshControl: UIRefreshControl) {
        self.refreshControl = refreshControl
        getGateways()
    }
    
    func getGateways(){
        let api_key = getApiKeyFromStore(for: DATACONNECT_API_KEY)
        let selectedOrgId = getSelectedOrgFromStore(for: SELECTED_ORG_ID)
        
        let selectedServer = getFromStore(for: "selectedProfileServer")
        let url = NSURL(string: "\(HTTPS + selectedServer + SERVICE_URL.ORGANIZATIONS2)/\(selectedOrgId)/gate_ways")
        
        var request = URLRequest(url: url! as URL)
        request.httpMethod = GET
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(api_key, forHTTPHeaderField: DATACONNECT_API_KEY)
        
        let defaultSession = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate: nil,
            delegateQueue: OperationQueue.main)
        
        print(url!)
        
        let task: URLSessionDataTask = defaultSession.dataTask(
            with: request,
            completionHandler:{ (data, response, error) in
                if let data = data, let response = response as? HTTPURLResponse {
                    if response.statusCode == 200 {
                        if let responseDict = try! JSONSerialization.jsonObject(
                            with: data, options:[]) as? Dictionary<String, Any>{
                            
                            self.gatewaysArray = responseDict["gate_ways"] as? [Dictionary<String, Any>]
                            
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

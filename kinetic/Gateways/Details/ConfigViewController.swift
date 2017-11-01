//
//  ConfigViewController.swift
//  dataconnect
//
//  Created by hienng on 10/21/17.
//  Copyright © 2017 cisco. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ConfigViewController: UIViewController, IndicatorInfoProvider,  UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var summarySections = ["Wifi"]
    var summaryArray: [String: Array<Any>] = [:]
    
    var apiKey: String?
    var selectedGateway: Int?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getGatewayDetails()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return  IndicatorInfo(title: "Current Config")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return summarySections[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return summarySections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let rowCount = summaryArray[summarySections[section]]?.count{
            return rowCount
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SummaryCell") as! SummaryTableViewCell
        
        if summaryArray[summarySections[indexPath.section]] != nil {
            let sectionDataArray = summaryArray[summarySections[indexPath.section]]
            let cellData = sectionDataArray![indexPath.row]  as? [String: Any]
            
            for (key, value) in cellData! {
                cell.keyLabel?.text = key
                cell.valueLabel?.text = value as? String
            }
        }
        
        return cell
    }
    
    func getGatewayDetails(){
        let api_key = getApiKeyFromStore(for: DATACONNECT_API_KEY)
        let selectedGateway = getSelectedOrgFromStore(for: SELECTED_GATEWAY_ID)
        
        let selectedServer = getFromStore(for: "selectedProfileServer")
        let url = NSURL(string: "\(HTTPS + selectedServer + SERVICE_URL.GATEWAYS)/\(selectedGateway)")
        
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
                            
                            print(responseDict)
                            
                            var wifiArr =  [Dictionary<String, Any>]()
                            
                            var wifiStatus = [String: Any](), lanPorts = [String: Any](), gps = [String: Any](),
                           workgroupBridge = [String: Any](), vpn = [String: Any](), privateSubnet = [String: Any]()
                                
                            for (key,value) in responseDict {
                                if key == "gateway_config"{
                                    let config = value as? Dictionary<String, Any>
                                    for(key, value) in config!{
                                        if key == "wifi_current_state"{
                                            let temp_key = "Wifi Status"
                                            wifiStatus = [temp_key:value]
                                        }
                                        else if key == "lan_ports_current_state"{
                                            let temp_key = "Lan Ports"
                                            lanPorts = [temp_key:value]
                                        }
                                        else if key == "gps_current_state"{
                                            let temp_key = "GPS"
                                            gps = [temp_key:value]
                                        }
                                        else if key == "wgb_current_state"{
                                            let temp_key = "WorkGroup Bridge"
                                            workgroupBridge = [temp_key:value]
                                        }
                                    }
                                    
                                }
                            }
                            
                            wifiArr = [wifiStatus, lanPorts, gps, workgroupBridge]
                            
                            self.summaryArray[self.summarySections[0]] = wifiArr
                            
                            self.tableView.reloadData()
                            //self.refreshControl.endRefreshing(
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

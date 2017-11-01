//
//  SummaryViewController.swift
//  dataconnect
//
//  Created by hienng on 10/21/17.
//  Copyright © 2017 cisco. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class SummaryViewController: UIViewController, IndicatorInfoProvider,  UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var summarySections = ["Gateway", "Address", "Cellular"]
    
    //var summaryArray: [Dictionary<String, Any>]?
    var summaryArray: [String: Array<Any>] = [:]
    
    var apiKey: String?
    var selectedGateway: Int?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getGatewayDetails()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IndicatorInfoProvider
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return  IndicatorInfo(title: "Summary")
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print ("selectedRow")
        //self.performSegue(withIdentifier: "SHOW_GATEWAY_DETAILS", sender: self)
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
                            
                            var addressArr =  [Dictionary<String, Any>]()
                            var gatewayArr = [Dictionary<String, Any>]()
                            var cellularArr = [Dictionary<String, Any>]()
                            
                            var serial = [String: Any](), make = [String: Any](), model  = [String: Any](),
                                swVersion  = [String: Any](), ioxVersion  = [String: Any](), macAddress = [String: Any]()
                     
                            var address1 = [String: Any](), address2 = [String: Any](), city = [String: Any](),
                            state = [String: Any](), country = [String: Any](), zipcode = [String: Any]()
                            
                            var cellStatus = [String: Any](), cellNetwork = [String: Any](), cellIP = [String: Any](),
                            vpnTunnelStatus = [String: Any](), vpnTunnelIP = [String: Any]()

                            for (key,value) in responseDict {
                                print("\(key) = \(value)")
                                if key == "uuid"{
                                    let temp_key = "Serial Number"
                                    serial = [temp_key: value]
                                }
                                else if key == "make"{
                                    let temp_key = "Make"
                                    make = [temp_key: value]
                                }
                                else if key == "model"{
                                    let temp_key = "Model"
                                    model = [temp_key: value]
                                }
                                else if key == "sw_version"{
                                    let temp_key = "Software Version"
                                    swVersion = [temp_key: value]
                                }
                                else if key == "iox_version"{
                                    let temp_key = "IoX Version"
                                    ioxVersion = [temp_key: value]
                                }
                                else if key == "mac_address"{
                                    let temp_key = "Mac Address"
                                    macAddress = [temp_key: value]
                                }
                                
                                else if key == "address"{
                                    let address = value as? Dictionary<String, Any>
                                    
                                    for (key, value) in address! {
                                        if key == "address_1"{
                                            let temp_key = "Address 1"
                                            address1 = [temp_key:value]
                                        }
                                        else if key == "address_2"{
                                            let temp_key = "Address 2"
                                           address2 = [temp_key:value]
                                        }
                                        else if key == "city"{
                                            let temp_key = "City"
                                            city = [temp_key:value]
                                        }
                                        else if key == "state"{
                                            let temp_key = "State"
                                            state = [temp_key:value]
                                        }
                                        else if key == "zipcode"{
                                            let temp_key = "Zipcode"
                                            zipcode = [temp_key:value]
                                        }
                                        else if key == "country"{
                                            let temp_key = "Country"
                                            country = [temp_key:value]
                                        }
                                    }
                                }
                                
                                else if key == "cellular_detail"{
                                    let cellular = value as? Dictionary<String, Any>
                                    for (key, value) in cellular! {
                                        if key == "cellular_status"{
                                            let temp_key = "Cellular Status"
                                            cellStatus = [temp_key:value]
                                        }
                                        else if key == "cellular_network_name"{
                                            let temp_key = "Cellular Carrier"
                                            cellNetwork = [temp_key:value]
                                        }
                                        else if key == "carrier_ip_address"{
                                            let temp_key = "Carier IP Address"
                                            cellIP = [temp_key:value]
                                        }
                                    }
                                }
                                
                                else if key == "gateway_config"{
                                    let config = value as? Dictionary<String, Any>
                                    for(key, value) in config!{
                                        if key == "customer_vpn_tunnel_status"{
                                            let temp_key = "Site-to-site VPN Tunnel"
                                            vpnTunnelStatus = [temp_key:value]
                                        }
                                        else if key == "customer_vpn_tunnel_ip_address"{
                                            let temp_key = "Site-to-site VPN Tunnel IP"
                                            vpnTunnelIP = [temp_key:value]
                                        }
                                    }
                                    
                                }
                            }
                           
                            gatewayArr = [serial, make, model, swVersion, ioxVersion, macAddress]
                            addressArr = [address1, address2, city, state, zipcode, country]
                            cellularArr = [cellStatus, cellNetwork, cellIP, vpnTunnelStatus, vpnTunnelIP]
                            
                            self.summaryArray[self.summarySections[0]] = gatewayArr
                            self.summaryArray[self.summarySections[1]] = addressArr
                            self.summaryArray[self.summarySections[2]] = cellularArr
                            
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

//
//  ScannerViewController.swift
//  dataconnect
//
//  Created by hienng on 10/16/17.
//  Copyright © 2017 cisco. All rights reserved.
//

import UIKit
import AVFoundation
import AFNetworking
import NVActivityIndicatorView

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, NVActivityIndicatorViewable {

    //var device = AVCaptureDevice.default(for: AVMediaType.video)!
    var output = AVCaptureMetadataOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var captureSession = AVCaptureSession()
    var scannedCode = UILabel()
    
    var apiKey: String?
    var selectedProfileServer: String?
    var selectedOrgId: Int?

    let supportedCodeTypes = [AVMetadataObject.ObjectType.upce, AVMetadataObject.ObjectType.code39, AVMetadataObject.ObjectType.code39Mod43, AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.ean8, AVMetadataObject.ObjectType.code93, AVMetadataObject.ObjectType.code128, AVMetadataObject.ObjectType.pdf417, AVMetadataObject.ObjectType.qr, AVMetadataObject.ObjectType.aztec]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationItems()
        if (captureSession.isRunning == false) {
            captureSession.startRunning();
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession.isRunning == true) {
            captureSession.stopRunning();
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //self.navigationController?.topViewController?.title = "Scanner"
        
        self.tabBarController?.navigationItem.title = "Claim Gateway"
        
        self.setupCamera()
        self.addLabelForDisplayingCode()
        setupNavigationItems()
       // claimGateway(with: "Gateway: PID:IOT-GW410-GATEWAY,SN:HWC21130001")
        //qrParserForVega("Gateway: PID:IOT-GW410-GATEWAY,SN:HWC21130001")
    }
    
    func setupNavigationItems(){
        //        let items = ["List", "Maps"]
        //        segmentedController = UISegmentedControl(items: items)
        //        segmentedController.selectedSegmentIndex = 0
        //        //self.navigationController?.topViewController.titleView = segmentedController
        //        self.tabBarController?.navigationItem.titleView = segmentedController
        
        let label = UILabel()
        label.text = "Claim Gateway"
        self.tabBarController?.navigationItem.titleView = label
        
        self.tabBarController?.navigationItem.rightBarButtonItem = nil
        
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        if (captureSession.isRunning == true) {
            captureSession.stopRunning();
        }
    }
    
    private func setupCamera() {

        let device = AVCaptureDevice.default(for: AVMediaType.video)
        
        guard device != nil else{
            return
        }
        
        do{
            let input = try AVCaptureDeviceInput(device: device!)
            
            if self.captureSession.canAddInput(input) {
                self.captureSession.addInput(input)
            }

            self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)

            if let videoPreviewLayer = self.previewLayer {
                    videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    videoPreviewLayer.frame = self.view.bounds
                    view.layer.addSublayer(videoPreviewLayer)
            }

            let metadataOutput = AVCaptureMetadataOutput()
            if (self.captureSession.canAddOutput(metadataOutput)) {
                    self.captureSession.addOutput(metadataOutput)

                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = supportedCodeTypes
            } else {
                print("Could not add metadata output")
            }
            
            qrCodeFrameView = UIView()
            if let qrCodeFrameView = qrCodeFrameView{
                qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubview(toFront: qrCodeFrameView)
            }
        }
        catch{
            print(error)
            return
        }
    }

    private func addLabelForDisplayingCode() {
        view.addSubview(scannedCode)
        scannedCode.translatesAutoresizingMaskIntoConstraints = false
        scannedCode.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50.0).isActive = true
        scannedCode.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20.0).isActive = true
        scannedCode.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20.0).isActive = true
        scannedCode.heightAnchor.constraint(equalToConstant: 50).isActive = true
        scannedCode.font = UIFont.preferredFont(forTextStyle: .title2)
        scannedCode.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        scannedCode.textAlignment = .center
        scannedCode.textColor = UIColor.white
        scannedCode.text = "Scanning...."
    }
    
    

    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection){
        // This is the delegate'smethod that is called when a code is readed
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            scannedCode.text = "No QR code is detected"
            return
        }
        print(metadataObjects)
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = previewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                scannedCode.text = metadataObj.stringValue
                claimGateway(with: scannedCode.text!)
            }
            else{
                scannedCode.text = "Not a valid code"
            }
        }
        
    }
    
    private func matches(for regex: String, in text: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                
                let s = String(text[Range($0.range, in: text)!])
                let indexStartOfText = s.index(s.startIndex, offsetBy: 3)
                let substring = s[indexStartOfText...]
                return String(substring)
            }
            
        } catch let error {
            print("Invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    //MARK - Parse Vega QR Code
    private func qrParserForVega(_ string:String) -> [String]{
        
        var result = [String]()
        let vegaRegexPattern = "SN:([a-zA-Z0-9]*)$"
        
        let serialNumbers = matches(for: vegaRegexPattern, in: string)

        if serialNumbers.count > 0 {
            result = serialNumbers
        }
        else{
            result = [string]
        }
        
        print(result)
        
        return result
    }

    func claimGateway(with id: String){
        apiKey = getApiKeyFromStore(for: DATACONNECT_API_KEY)
        let server = getFromStore(for: "selectedProfileServer")
        let orgId = String(getSelectedOrgFromStore(for: SELECTED_ORG_ID))
        let size = CGSize(width: 50, height: 50)
        let serial_numbers = qrParserForVega(id)
        
        startAnimating(size, message: "Claiming Gateway \(serial_numbers[0])", type: NVActivityIndicatorType(rawValue: 23))
        
        let url = NSURL(string: "\(HTTPS + server +  SERVICE_URL.ORGANIZATION_FOR_CLAIM + "/" + orgId + SERVICE_URL.CLAIM)")
        var request = URLRequest(url: url! as URL)
        request.httpMethod = POST
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(apiKey!, forHTTPHeaderField: DATACONNECT_API_KEY)
        
        let params: Dictionary<String,AnyObject> = ["claim_ids": serial_numbers as AnyObject]
        
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
                            
                            if let success = responseObject["success"] as? NSDictionary{
                                let s: NSArray = success["succeeded_ids"] as! NSArray
                                
                                if s.count > 0 {
                                    
                                    NVActivityIndicatorPresenter.sharedInstance.setMessage("Successfully claimed gateway \(serial_numbers[0])")
                                    
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                                        self.stopAnimating()
                                    }
                                }
                            }
                            
                            if let failures = responseObject["errors"] as? NSDictionary {
                                let failed_in_org = failures["failed_already_present_in_this_org_ids"] as! NSArray
                                let failed_in_different_org = failures["failed_already_present_in_a_different_org_ids"] as! NSArray
                                let failed_invalid_ids = failures["invalid_ids"] as! NSArray

                                if failed_in_org.count > 0{
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                                        NVActivityIndicatorPresenter.sharedInstance.setMessage("Gateway \(serial_numbers[0]) is already in this org")
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4.5) {
                                        self.stopAnimating()
                                    }
                                }
                                else if failed_in_different_org.count > 0{
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                                        NVActivityIndicatorPresenter.sharedInstance.setMessage("Gateway \(serial_numbers[0]) is already in a different org")
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4.5) {
                                        self.stopAnimating()
                                    }
                                }
                                else if failed_invalid_ids.count > 0 {
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                                        NVActivityIndicatorPresenter.sharedInstance.setMessage("Gateway \(serial_numbers[0]) is invalid")
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4.5) {
                                        self.stopAnimating()
                                    }
                                }

                            }
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

//
//  GatewaysDetailsViewController.swift
//  dataconnect
//
//  Created by hienng on 10/21/17.
//  Copyright © 2017 cisco. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class GatewaysDetailsViewController: ButtonBarPagerTabStripViewController {

    let blueInstagramColor = UIColor(red: 37/255.0, green: 111/255.0, blue: 206/255.0, alpha: 1.0)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationItems()
    }
    
    override func viewDidLoad() {
        
        // change selected bar color
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = blueInstagramColor
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black
            newCell?.label.textColor = self?.blueInstagramColor
        }
        
        super.viewDidLoad()
        setupNavigationItems()
        // Do any additional setup after loading the view.
    }
    
    func setupNavigationItems(){
        //        let items = ["List", "Maps"]
        //        segmentedController = UISegmentedControl(items: items)
        //        segmentedController.selectedSegmentIndex = 0
        //        //self.navigationController?.topViewController.titleView = segmentedController
        //        self.tabBarController?.navigationItem.titleView = segmentedController
        
        let label = UILabel()
        label.text = "Gateway Details"
        self.navigationItem.titleView = label
        
        self.navigationItem.rightBarButtonItem = nil
        
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
    }
    
    // MARK: - PagerTabStripDataSource
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let summaryTab = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GatewayDetailsSummary")
        let currentConfigTab = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GatewayDetailsConfig")
        return [summaryTab, currentConfigTab]
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

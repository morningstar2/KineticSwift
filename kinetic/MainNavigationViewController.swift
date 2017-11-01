//
//  MainNavigationViewController.swift
//  dataconnect
//
//  Created by hienng on 10/18/17.
//  Copyright © 2017 cisco. All rights reserved.
//

import UIKit

class MainNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // creates item with UIBarButtonSystemItemAction icon
        //self.navigationController!.navigationBar.barTintColor = UIColor.ciscoLightBlue()
        
//        let appearance = UIBarButtonItem.appearance()
//        appearance.setBackButtonTitlePositionAdjustment(UIOffset.init(horizontal: 0.0, vertical: -60), for: .default)
//        self.navigationBar.isTranslucent = true
        //self.navigationBar.barTintColor = UIColor.init(red: 100/255, green: 187/255, blue: 227/255, alpha: 0.8)
        
//        #if swift(>=4.0)
//            self.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.init(red: 38/255.0, green: 38/255.0, blue: 38/255.0, alpha: 1.0), NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16.0)]
//        #elseif swift(>=3.0)
//            self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.init(red: 38/255.0, green: 38/255.0, blue: 38/255.0, alpha: 1.0), NSFontAttributeName: UIFont.systemFont(ofSize: 16.0)];
//        #endif
//        self.navigationBar.tintColor = UIColor.init(red: 38/255.0, green: 38/255.0, blue: 38/255.0, alpha: 1.0)
//        self.navigationItem.title = "Example"
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

//
//  MainTabBarController.swift
//  dataconnect
//
//  Created by hienng on 10/15/17.
//  Copyright © 2017 cisco. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {

    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        print ("logout")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC  = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.present(loginVC, animated: true, completion: nil)
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

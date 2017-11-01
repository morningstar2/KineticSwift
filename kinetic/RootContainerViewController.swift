//
//  RootContainerViewController.swift
//  dataconnect
//
//  Created by hienng on 9/20/17.
//  Copyright © 2017 cisco. All rights reserved.
//

import UIKit


class RootContainerViewController: UIViewController {

    fileprivate var rootViewController: UIViewController? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showSplashViewController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showSplashViewController() {
        showSplashViewControllerNoPing()
        
        delay(6.00) {
            //self.loadDummyProfile()
            self.showMenuNavigationViewController()
        }
    }
    
    func loadDummyProfile(){
        
        let profiles = [ Profile(id: 0, name: "joker", server: "joker.iotspdev.io", username: "joker@cisco.com", password: "C!sc01234") ,
                         Profile(id: 0, name: "qedev", server: "qedev.iotspdev.io", username: "gwaas-iot@cisco.com", password: "C!sc0123"),
                         Profile(id: 0, name: "cyclops", server: "cyclops.iotspdev.io", username: "psooryan@cisco.com", password: "C!sc0123"),
                         Profile(id: 0, name: "karan", server: "joker.iotspdev.io", username: "karansi@cisco.com", password: "C!sc0123")]
        
        for p in profiles {
            if let id = KineticDB.instance.addProfile(profile: p){
                print("created profile with id \(id)")
            }
        }
    }
    
    func showSplashViewControllerNoPing(){
        if rootViewController is SplashViewController {
            return
        }
    
        rootViewController?.willMove(toParentViewController: nil)
        rootViewController?.removeFromParentViewController()
        rootViewController?.view.removeFromSuperview()
        rootViewController?.didMove(toParentViewController: nil)
        
        let splashViewController = SplashViewController(tileViewFileName: "Grid")
        rootViewController = splashViewController
        splashViewController.pulsing = true
        
        splashViewController.willMove(toParentViewController: self)
        addChildViewController(splashViewController)
        view.addSubview(splashViewController.view)
        splashViewController.didMove(toParentViewController: self)
        
    }
    
    /// Displays the LoginViewController
    func showMenuNavigationViewController() {
        guard !(rootViewController is MenuNavigationViewController) else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let login =  storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        login.willMove(toParentViewController: self)
        addChildViewController(login)
        
        if let rootViewController = self.rootViewController {
            self.rootViewController = login
            rootViewController.willMove(toParentViewController: nil)
            
            transition(from: rootViewController, to: login, duration: 0.55, options: [.transitionCrossDissolve, .curveEaseOut], animations: { () -> Void in
                
            }, completion: { _ in
                login.didMove(toParentViewController: self)
                rootViewController.removeFromParentViewController()
                rootViewController.didMove(toParentViewController: nil)
            })
        } else {
            rootViewController = login
            view.addSubview(login.view)
            login.didMove(toParentViewController: self)
        }
    }
    

    override var prefersStatusBarHidden : Bool {
        switch rootViewController  {
        case is SplashViewController:
            return true
        case is MenuNavigationViewController:
            return false
        default:
            return false
        }
    }

}

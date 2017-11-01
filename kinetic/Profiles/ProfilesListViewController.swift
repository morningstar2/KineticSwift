//
//  ProfilesListViewController.swift
//  dataconnect
//
//  Created by hienng on 10/14/17.
//  Copyright © 2017 cisco. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import MGSwipeTableCell

class ProfilesListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MGSwipeTableCellDelegate, NVActivityIndicatorViewable {

    @IBOutlet weak var tableView: UITableView!
    
    var profilesArray = [Profile]()
    var selectedProfile: Profile?
    var refreshControl = UIRefreshControl()
    
    let activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 100, y: 100, width: 150, height: 150), type: .ballSpinFadeLoader, color: UIColor.white, padding: CGFloat(0))
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBarItems()
        getProfiles()
        
         NotificationCenter.default.addObserver(self, selector: #selector(self.databaseStatusChanged(_:)), name: NSNotification.Name(rawValue: KINETIC_DB_STATUS_CHANGED), object: nil)
    }
    
    @objc func databaseStatusChanged (_ notification: NSNotification){
        guard let userInfo = notification.userInfo, let message  = userInfo["message"] as? String
            else {
                debugPrint("No userInfo.message found in notification")
                return
        }
        
        let size = CGSize(width: 25, height: 25)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            self.startAnimating(size, message: message, type: NVActivityIndicatorType(rawValue: 23))
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            self.stopAnimating()
        }
        
    }
    
    private func getProfiles() {
        profilesArray =  KineticDB.instance.getProfiles()
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(
            self,
            action: #selector(refreshControlAction(refreshControl:)),
            for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        refreshControlAction(refreshControl: refreshControl)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        profilesArray =  KineticDB.instance.getProfiles()

        setupNavigationBarItems()
    }
    
    // Private action
    @objc fileprivate func profilesTapped() {
        selectedProfile = nil
        self.performSegue(withIdentifier: "EDIT_PROFILE_SEGUE", sender: self)
    }
    
    @objc func refreshControlAction(refreshControl: UIRefreshControl) {
        self.refreshControl = refreshControl
        getProfiles()
    }
    
    private func setupNavigationBarItems(){
        
        let label = UILabel()
        label.text = "Profiles"
        self.tabBarController?.navigationItem.titleView = label
        
        let addProfile = UIButton(type: .system)
        addProfile.setImage(#imageLiteral(resourceName: "add_profile").withRenderingMode(UIImageRenderingMode.alwaysOriginal), for: .normal)
        addProfile.frame = CGRect(x: 0, y: 0, width: 34, height: 34)
        addProfile.contentMode = .scaleAspectFit
        addProfile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addProfileTapped)))
        self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addProfile)
        
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.isTranslucent = false
    }
    
    @objc private func addProfileTapped() {
        print("addProfile tapped")
       
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navController = storyboard.instantiateViewController(withIdentifier: "ProfilesNavigationController") as! MainNavigationViewController
        let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        navController.pushViewController(vc, animated: true)
        self.present(navController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profilesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell") as! ProfileTableViewCell
        cell.delegate = self
        cell.rightButtons = [MGSwipeButton(title: "Delete", backgroundColor: .red)]
        cell.rightSwipeSettings.transition = .rotate3D
        
        let cellData = profilesArray[indexPath.row]
        cell.serverName.text = cellData.server
        cell.profileName.text = cellData.name
        
        cell.cellData = cellData
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProfile = profilesArray[indexPath.row]
        self.selectedProfile = selectedProfile
        self.performSegue(withIdentifier: "EDIT_PROFILE_SEGUE", sender: self)
    }
    
    func swipeTableCell(_ cell: MGSwipeTableCell, tappedButtonAt index: Int, direction: MGSwipeDirection, fromExpansion: Bool) -> Bool {
        
        let size = CGSize(width: 25, height: 25)
        let profileCell = cell as! ProfileTableViewCell
        let cellData = profileCell.cellData
        let cellId = cellData?.id
 
        if index == 0 { //delete button tapped
            if KineticDB.instance.deleteProfile(cellId!){
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()) {
                    self.startAnimating(size, message: "Profile Deleted.", type: NVActivityIndicatorType(rawValue: 23))
                }
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
                    self.stopAnimating()
                    self.getProfiles()
                }
            }
            
            
        }
        return true
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "EDIT_PROFILE_SEGUE" {
            
            let destinationVC = segue.destination as! UINavigationController
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
            if let profile = selectedProfile {
                vc.selectedProfile = profile
            }
            destinationVC.pushViewController(vc, animated: true)
        
            
        }
    }
}

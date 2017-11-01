//
//  ReachabilityManager.swift
//  dataconnect
//
//  Created by hienng on 10/9/17.
//  Copyright © 2017 cisco. All rights reserved.
//

import UIKit
import ReachabilitySwift

//Protocol for listening to network status change
public protocol NetworkStatusListener: class{
    func networkStatusDidChange(status: Reachability.NetworkStatus)
}

class ReachabilityManager: NSObject {
    static let shared = ReachabilityManager() //sets up the shared instance
    
    //tracks network reachability
    var isNetworkAvailable: Bool {
        return reachabilityStatus != .notReachable
    }
    
    //tracks current NetworkStatus (notReachable, reachableViaWifi, reachableViaWWAN)
    var reachabilityStatus: Reachability.NetworkStatus = .notReachable
    
    //Reachability instance for Network status monitoring
    let reachability = Reachability()
    
    //Array of delegates which are interested in listening to network status change
    var listeners = [NetworkStatusListener]()
    
    /**
     Function to call whenever there is a change in NetworkReachability Status
    */
    @objc func reachabilityChanged(notification: Notification) {
        let reachability = notification.object as! Reachability
        
        switch reachability.currentReachabilityStatus {
        case .notReachable:
            debugPrint("Network became unreachable")
        case .reachableViaWiFi:
            debugPrint("Network is reachable through Wifi")
        case .reachableViaWWAN:
            debugPrint("Network reachable through Cellular Data")
        }
        
        //Send message to each of the delegates
        for listener in listeners {
            listener.networkStatusDidChange(status: reachability.currentReachabilityStatus)
        }
    }
    
    //Starts monitoring the network availability status
    func startMonitoring () {
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: ReachabilityChangedNotification, object: reachability)
        do {
            try reachability?.startNotifier()
        }
        catch{
            debugPrint("Could not start reachability notifier")
        }
    }
    
    //Stops monitoring the network availability status
    func stopMonitoring () {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: reachability)
    }
    
    //Adds a new listener to the listeners array
    func addListener (listener: NetworkStatusListener){
        listeners.append(listener)
    }
    
    //Removes the listener from the listeners array
    func removeListener (listener: NetworkStatusListener) {
        listeners = listeners.filter{ $0 !== listener}
    }
}

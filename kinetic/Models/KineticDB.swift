//
//  KineticDB.swift
//  dataconnect
//
//  Created by hienng on 10/13/17.
//  Copyright © 2017 cisco. All rights reserved.
//

import Foundation
import SQLite


public protocol DatabaseStatusListener: class {
    func errorStatusChanged(status: NSError)
}

class KineticDB : NSObject {
    static let instance = KineticDB()
    private let db: Connection?
    
    private let profiles = Table("profiles")
    private let id = Expression<Int64>("id")
    private let name = Expression<String?>("name")
    private let server = Expression<String?>("server")
    private let username = Expression<String?>("username")
    private let password = Expression<String?>("password")
    
    let errorStatus = NSError()
    
    //Array of delegates which are interested in listening to database error statuses
    var listeners = [DatabaseStatusListener]()
    
    override init() {
        
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        
        do {
            db = try Connection("\(path)/KineticDB.sqlite3")
            print("created table")
        } catch {
            db = nil
            print ("Unable to open database")
        }
        
        super.init()
        
        //self.dropProfileTable()
        self.createProfileTable()
        
        
    }
    
    func dropProfileTable(){
        do {
            try db!.run(profiles.drop(ifExists: true))
        }
        catch {
            print("Unable to drop profiles table")
        }
    }
    
    func createProfileTable() {
        do {
            try db!.run(profiles.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(name, unique: true)
                table.column(server)
                table.column(username)
                table.column(password)
            })
        } catch {
            print("Unable to create table")
        }
    }
    
    func addProfile(profile: Profile) -> Int64?{
        do {
            let insert = profiles.insert(name <- profile.name, server <- profile.server, username <- profile.username, password <- profile.password)
            let id = try db!.run(insert)
            
            debugPrint(insert.asSQL())
            
            return id
        }
        catch {
            print("insertion failed: \(error)")
            return -1
        }
    }
    
    func addProfile(pname: String, pserver: String, pusername: String, ppassword: String) -> Int64? {
        do {
            let insert = profiles.insert(name <- pname, server <- pserver, username <- pusername, password <- ppassword)
            let id = try db!.run(insert)
            
            debugPrint(insert.asSQL())
            
            return id
        }
        catch let Result.error(message, code, _) where code == 19 {
            let errorMessage = "Constraint Failed: \(message)"
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KINETIC_DB_STATUS_CHANGED), object: nil, userInfo: ["message": errorMessage] )
            return -1
        }
        catch let error {
            let errorMessage = "Insertion Failed: \(error)"
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KINETIC_DB_STATUS_CHANGED), object: nil, userInfo: ["message": errorMessage] )
            return -1
        }
    }
    
    func getProfiles() -> [Profile] {
        var profiles = [Profile]()
        
        do{
            for profile in try db!.prepare(self.profiles){
                profiles.append(Profile(id: profile[id], name: profile[name]!, server: profile[server]!, username: profile[username]!, password: profile[password]!))
            }
        }
        catch{
            debugPrint("getProfiles failed")
        }
        
        return profiles
    }
    
    func updateProfile( pid: Int64, newProfile: Profile) -> Bool? {
        let profile = profiles.filter(id == pid)
        do {
            let update = profile.update([
                name <- newProfile.name,
                server <- newProfile.server,
                username <- newProfile.username,
                password <- newProfile.password
                ])
            if try db!.run(update) > 0 {
                return true
            }
        } catch {
            print("Update failed: \(error)")
            let errorMessage = "Update Failed: \(error)"
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KINETIC_DB_STATUS_CHANGED), object: nil, userInfo: ["message": errorMessage] )
            
        }
        
        return false
    }
    
    func deleteProfile(_ pid: Int64) -> Bool {
        do{
            let profile = profiles.filter(id == pid)
            try db!.run(profile.delete())
            return true
        }
        catch{
            debugPrint("Delete Failed")
            let errorMessage = "Delete Failed: \(error)"
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: KINETIC_DB_STATUS_CHANGED), object: nil, userInfo: ["message": errorMessage] )
        }
        return false
    }
    
    @objc func statusChanged(notification: Notification){
        
        //Send message to each of the delegates
        for listener in listeners {
            listener.errorStatusChanged(status: errorStatus)
        }
    }
    
    //Adds a new listener to the listeners array
    func addListener (listener: DatabaseStatusListener){
        listeners.append(listener)
    }
    
    //Removes the listener from the listeners array
    func removeListener (listener: DatabaseStatusListener) {
        listeners = listeners.filter{ $0 !== listener}
    }
    
}

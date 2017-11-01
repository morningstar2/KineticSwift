//
//  Profile.swift
//  dataconnect
//
//  Created by hienng on 10/6/17.
//  Copyright © 2017 cisco. All rights reserved.
//

import UIKit
public class Profile {
    var id: Int64?
    var name: String
    var server: String
    var username: String
    var password: String
    
    init(id: Int64){
        self.id = id
        name = ""
        server = ""
        username = ""
        password = ""
    }
    init(id: Int64, name: String, server: String, username: String, password: String){
        self.id = id
        self.name = name
        self.server = server
        self.username = username
        self.password = password
    }
    
//    required convenience init?(coder aDecoder: NSCoder) {
//        let id = aDecoder.decodeInteger(forKey: "id")
//        let name = aDecoder.decodeObject(forKey: "name") as! String
//        let server = aDecoder.decodeObject(forKey: "server") as! String
//        let username = aDecoder.decodeObject(forKey: "username") as! String
//        let password = aDecoder.decodeObject(forKey: "password") as! String
//        self.init(name: name, server: server, username: username, password: password)
//    }
//
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(id, forKey: "id")
//        aCoder.encode(name, forKey: "name")
//        aCoder.encode(server, forKey: "server")
//        aCoder.encode(username, forKey: "username")
//        aCoder.encode(password, forKey: "password")
//    }
    

}

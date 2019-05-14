//
//  User.swift
//  CrudCloudFirestore
//
//  Created by GraceToa on 06/05/2019.
//  Copyright © 2019 GraceToa. All rights reserved.
//

import Foundation

class User {
    var name: String
    var lastname: String
    var id: String
    var image: String
    var email: String
    
    
    init(name:String, lastname: String, id: String, email: String, image: String) {
        self.name = name
        self.lastname = lastname
        self.id = id
        self.email = email
        self.image = image
    }

    
}

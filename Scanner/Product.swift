//
//  Product.swift
//  Scanner
//
//  Created by Jim on 2018-05-16.
//  Copyright © 2018 Jim. All rights reserved.
//

import UIKit

class Product{
    //Mark: Properties
    var name: String
    var photo: UIImage?
    var id: String
    var upc: String?
    var exp: Date?
    
    //Mark: Initializations
    init?(name: String, photo: UIImage?, id: String, upc: String?, exp: Date?) {
        // Initialization should fail if there is no name or if the rating is negative.
        guard !name.isEmpty else{
            return nil
        }
        self.name = name
        self.photo = photo
        self.id = id
        self.upc = upc
        self.exp = exp
    }
}

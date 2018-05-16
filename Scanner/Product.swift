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
    var id: Int
    var upc: String?
    //Mark: Initializations
    init?(name: String, photo: UIImage?, id: Int, upc: String?) {
        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty || id < 0  {
            return nil
        }

        self.name = name
        self.photo = photo
        self.id = id
        self.upc = upc
        
    }
}

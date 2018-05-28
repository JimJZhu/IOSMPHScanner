//
//  ModelController.swift
//  Scanner
//
//  Created by Jim on 2018-05-28.
//  Copyright © 2018 Jim. All rights reserved.
//

import Foundation
import FirebaseDatabase

class ModelController {
    var products = [Product]()
    var sortMethod: SortMethods = .ByName
    var sortedProducts :[Product]{
        switch sortMethod{
        case .ByExpiryDate :
            return products.sorted(by: {
                if let firstDate = $0.exp{
                    if let secondDate = $1.exp{
                        return firstDate > secondDate
                    }
                   return true
                }
                if $1.exp != nil{
                    return false
                }
                return true
            })
        case .ByHighestPrice :
            return products.sorted(by: {$0.highestPrice > $1.highestPrice})
        case .ByName :
            return products.sorted(by: {$0.name > $1.name})
        case .ByStock :
            return products.sorted(by: {$0.stock ?? 0 > $1.stock ?? 0})
        }
    }
    var searchText = ""
    var filteredProducts :[Product]{
        return products.filter({( product : Product) -> Bool in
            return product.name.lowercased().contains(searchText.lowercased())
        })
    }
    func loadProducts(from ref: DatabaseReference){
        ref.observe(.value, with: {(snapshot) in
            self.products.removeAll()
            for child in snapshot.children{
                guard let productSnapshot = child as? DataSnapshot else{
                    fatalError("Unable to cast as DataSnapshot")
                }
                guard let product = Product(snapshot: productSnapshot) else{
                    fatalError("Unable to instantiate product")
                }
                // Download the image on a background thread, so our UI can still update
                self.products += [product]
            }
        })
    }
}

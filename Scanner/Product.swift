//
//  Product.swift
//  Scanner
//
//  Created by Jim on 2018-05-16.
//  Copyright © 2018 Jim. All rights reserved.
//

import UIKit
import FirebaseDatabase

class Product{
    //Mark: Properties
    let ref: DatabaseReference?
    var name: String
    var photo: UIImage?
    var id: String
    var exp: Date?
    var amazonCAPrice: Double?
    var amazonCOMPrice: Double?
    var asin: String?
    var caSKU: String?
    var comSKU: String?
    var fbaCAPrice: Double?
    var fbaCOMPrice: Double?
    var ebayPrice: Double?
    var fifibabyPrice: Double?
    var imaplehousePrice: Double?
    var maplepetPrice: Double?
    var upcEAN: String?
    
    //Mark: Initializations
    init?(name: String, photo: UIImage?, id: String, upcEAN: String?, exp: Date?, amazonCAPrice: Double?, amazonCOMPrice: Double?, asin: String?, caSKU: String?, comSKU: String?, fbaCAPrice: Double?, fbaCOMPrice: Double?, ebayPrice: Double?, fifibabyPrice: Double?, imaplehousePrice: Double?, maplepetPrice: Double?, ref: DatabaseReference?) {
        guard !name.isEmpty else{
            return nil
        }
        guard !id.isEmpty else{
            return nil
        }
        self.ref = ref
        self.id = id
        self.name = name
        self.photo = photo
        self.amazonCAPrice = amazonCAPrice
        self.amazonCOMPrice = amazonCOMPrice
        self.asin = asin
        self.caSKU = caSKU
        self.comSKU = comSKU
        self.fbaCAPrice = fbaCAPrice
        self.fbaCOMPrice = fbaCOMPrice
        self.ebayPrice = ebayPrice
        self.exp = exp
        self.fifibabyPrice = fifibabyPrice
        self.imaplehousePrice = imaplehousePrice
        self.maplepetPrice = maplepetPrice
        self.upcEAN = upcEAN
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let name = value["name"] as? String else {
            return nil
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        self.ref = snapshot.ref
        self.id = snapshot.key
        self.name = name
        self.photo = nil
        self.amazonCAPrice = value["amzn_ca_price"] as? Double
        self.amazonCOMPrice = value["amzn_com_price"] as? Double
        self.asin = value["asin"] as? String
        self.caSKU = value["ca_sku"] as? String
        self.comSKU = value["com_sku"] as? String
        self.fbaCAPrice = value["fba_ca_price"] as? Double
        self.fbaCOMPrice = value["fba_com_price"] as? Double
        self.ebayPrice = value["ebay_price"] as? Double
        if let dateString = value["exp"] as? String{
            self.exp = dateFormatter.date(from:dateString)
        }else{
            self.exp = nil
        }
        self.fifibabyPrice = value["fifibaby_price"] as? Double
        self.imaplehousePrice = value["imaplehouse_price"] as? Double
        self.maplepetPrice = value["maplepet_price"] as? Double
        self.upcEAN = value["upc_ean"] as? String
    }
}

//
//  Product.swift
//  Scanner
//
//  Created by Jim on 2018-05-16.
//  Copyright © 2018 Jim. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class Product{
    //MARK: Properties
    let ref: DatabaseReference?
    var name: String
    var imageURL: URL?
    let id: String
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
    let dateFormatter: DateFormatter

    //MARK: Initializations
    init?(name: String, imageURL: URL?, id: String, upcEAN: String?, exp: Date?, amazonCAPrice: Double?, amazonCOMPrice: Double?, asin: String?, caSKU: String?, comSKU: String?, fbaCAPrice: Double?, fbaCOMPrice: Double?, ebayPrice: Double?, fifibabyPrice: Double?, imaplehousePrice: Double?, maplepetPrice: Double?, ref: DatabaseReference?) {
        guard !name.isEmpty else{
            return nil
        }
        guard !id.isEmpty else{
            return nil
        }
        
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        self.ref = ref
        self.id = id
        self.name = name
        self.imageURL = imageURL
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
        self.dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        self.ref = snapshot.ref
        self.id = snapshot.key
        self.name = name
        self.asin = value["asin"] as? String
        if let amazonCAPriceText = value["amzn_ca_price"] as? String{
            self.amazonCAPrice = Double(amazonCAPriceText)
        }else{
            self.amazonCAPrice = nil
        }
        if let amazonCOMPriceText = value["amzn_com_price"] as? String{
            self.amazonCOMPrice = Double(amazonCOMPriceText)
        }else{
            self.amazonCOMPrice = nil
        }
        if let ebayPriceText = value["ebay_price"] as? String{
            self.ebayPrice = Double(ebayPriceText)
        }else{
            self.ebayPrice = nil
        }
        if let fbaCAPriceText = value["fba_ca_price"] as? String{
            self.fbaCAPrice = Double(fbaCAPriceText)
        }else{
            self.fbaCAPrice = nil
        }
        if let fbaCOMPriceText = value["fba_com_price"] as? String{
            self.fbaCOMPrice = Double(fbaCOMPriceText)
        }else{
            self.fbaCOMPrice = nil
        }
        if let imaplehousePriceText = value["imaplehouse_price"] as? String{
            self.imaplehousePrice = Double(imaplehousePriceText)
        }else{
            self.imaplehousePrice = nil
        }
        if let fifibabyPriceText = value["fifibaby_price"] as? String{
            self.fifibabyPrice = Double(fifibabyPriceText)
        }else{
            self.fifibabyPrice = nil
        }
        if let maplepetPriceText = value["maplepet_price"] as? String{
            self.maplepetPrice = Double(maplepetPriceText)
        }else{
            self.maplepetPrice = nil
        }
        if let imageURLText = value["image_url"] as? String{
            self.imageURL = URL(string: imageURLText)
        }else{
            self.imageURL = nil
        }
        self.asin = value["asin"] as? String
        self.caSKU = value["ca_sku"] as? String
        self.comSKU = value["com_sku"] as? String
        if let dateString = value["exp"] as? String{
            self.exp = dateFormatter.date(from:dateString)
        }else{
            self.exp = nil
        }
        self.upcEAN = value["upc_ean"] as? String
    }
    
    func toAnyObject() -> NSDictionary {
        var amazonCAPriceString: String = ""
        var amazonCOMPriceString: String = ""
        var ebayPriceString: String = ""
        var fbaCAPriceString: String = ""
        var fbaCOMPriceString: String = ""
        var expString: String = ""
        var fifibabyPriceString: String = ""
        var imaplehousePriceString: String = ""
        var maplepetPriceString: String = ""
        if let amazonCAPrice = amazonCAPrice{
            amazonCAPriceString = String(format:"%.5f", amazonCAPrice)
        }
        if let amazonCOMPrice = amazonCOMPrice{
            amazonCOMPriceString = String(format:"%.5f", amazonCOMPrice)
        }
        if let fbaCAPrice = fbaCAPrice{
            fbaCAPriceString = String(format:"%.5f", fbaCAPrice)
        }
        if let fbaCOMPrice = fbaCOMPrice{
            fbaCOMPriceString = String(format:"%.5f", fbaCOMPrice)
        }
        if let ebayPrice = ebayPrice{
            ebayPriceString = String(format:"%.5f", ebayPrice)
        }
        if let exp = exp{
            expString = dateFormatter.string(from: exp)
        }
        if let fifibabyPrice = fifibabyPrice{
            fifibabyPriceString = String(format:"%.5f", fifibabyPrice)
        }
        if let imaplehousePrice = imaplehousePrice{
            imaplehousePriceString = String(format:"%.5f", imaplehousePrice)
        }
        if let maplepetPrice = maplepetPrice{
            maplepetPriceString = String(format:"%.5f", maplepetPrice)
        }
        return [
            "asin" : asin ?? "",
            "ca_sku" : caSKU ?? "",
            "com_sku" : comSKU ?? "",
            "fba_ca_price" : fbaCAPriceString,
            "fba_com_price" : fbaCOMPriceString,
            "upc_ean" : upcEAN ?? "",
            "amzn_ca_price" : amazonCAPriceString,
            "amzn_com_price" : amazonCOMPriceString,
            "ebay_price" : ebayPriceString,
            "exp" : expString,
            "fifibaby_price" : fifibabyPriceString,
            "imaplehouse_price" : imaplehousePriceString,
            "maplepet_price" : maplepetPriceString,
            "name" : name,
            "imageURL" : imageURL?.absoluteString ?? "idklol"
        ]
    }
}

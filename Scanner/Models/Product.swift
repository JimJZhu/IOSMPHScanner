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
    var stock: Int?
    let dateFormatter: DateFormatter
    var highestPrice: Double {
        let priceArray = [amazonCAPrice ?? 0, amazonCOMPrice ?? 0,
                          fifibabyPrice ?? 0, imaplehousePrice ?? 0,fbaCOMPrice ?? 0]
        return priceArray.max() ?? 0
    }
    //MARK: Initializations
    init?(name: String, imageURL: URL?, id: String, upcEAN: String?, exp: Date?, amazonCAPrice: Double?, amazonCOMPrice: Double?, asin: String?, caSKU: String?, comSKU: String?, fbaCAPrice: Double?, fbaCOMPrice: Double?, ebayPrice: Double?, fifibabyPrice: Double?, imaplehousePrice: Double?, maplepetPrice: Double?, stock: Int?, ref: DatabaseReference?) {
        guard !name.isEmpty else{
            return nil
        }
        guard !id.isEmpty else{
            return nil
        }
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
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
        self.stock = stock
    }
    
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: AnyObject],
            let name = value["name"] as? String else {
            return nil
        }
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
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
        self.stock = value["stock"] as? Int
    }
    
    func toAnyObject() -> NSDictionary {
        return [
            "asin" : asin ?? "",
            "ca_sku" : caSKU ?? "",
            "com_sku" : comSKU ?? "",
            "fba_ca_price" : fbaCAPrice.longPriceString,
            "fba_com_price" : fbaCOMPrice.longPriceString,
            "upc_ean" : upcEAN ?? "",
            "amzn_ca_price" : amazonCAPrice.longPriceString,
            "amzn_com_price" : amazonCOMPrice.longPriceString,
            "ebay_price" : ebayPrice.longPriceString,
            "exp" : exp.isoDateString,
            "fifibaby_price" : fifibabyPrice.longPriceString,
            "imaplehouse_price" : imaplehousePrice.longPriceString,
            "maplepet_price" : maplepetPrice.longPriceString,
            "name" : name,
            "image_url" : imageURL?.absoluteString ?? "idklol",
            "stock" : stock ?? "0"
        ]
    }
}
extension Optional where Wrapped == Double {
    var longPriceString: String {
        if let value = self{
            return String(format:"%.5f", value)
        }
        return ""
    }
}
extension Optional where Wrapped == Date {
    var isoDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        if let value = self{
            return dateFormatter.string(from: value)
        }
        return ""
    }
}

//
//  ProductTableViewCell.swift
//  Scanner
//
//  Created by Jim on 2018-05-16.
//  Copyright © 2018 Jim. All rights reserved.
//

import UIKit

class ProductTableViewCell: UITableViewCell {
    
    //Mark: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var expiryDateLabel: UILabel!
    @IBOutlet weak var upcCodeLabel: UILabel!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var skuLabel: UILabel!
    @IBOutlet weak var asinLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var stockLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

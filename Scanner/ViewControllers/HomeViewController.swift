//
//  HomeViewController.swift
//  Scanner
//
//  Created by Jim on 2018-05-28.
//  Copyright © 2018 Jim. All rights reserved.
//

import UIKit
import FirebaseDatabase

class HomeViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var totalStockLabel: UILabel!
    
    //MARK: - Properties
    var databaseRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Gets firebase references
        databaseRef = Database.database().reference().child("products")
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

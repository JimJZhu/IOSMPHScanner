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
    var labels: [UILabel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labels = createLabelArray(totalStockLabel)
        // Gets firebase references
        databaseRef = Database.database().reference().child("products")
        // Load Data
        loadData(from: databaseRef)
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

    //MARK: - Private Functions
    func loadData(from ref: DatabaseReference){
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
    func createLabelArray(with labels: UILabel...){
        var array: [UILabel] = []
        for label: UILabel in labels{
            array.append(label)
        }
    }
}

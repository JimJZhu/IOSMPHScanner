//
//  SettingsViewController.swift
//  Scanner
//
//  Created by Jim on 2018-05-23.
//  Copyright © 2018 Jim. All rights reserved.
//

import UIKit
import FirebaseAuth

class SettingsViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var accountTypeLabel: UILabel!
    @IBOutlet weak var privilegesLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        accountTypeLabel.text = "Account: \(String(describing: Auth.auth().currentUser?.email ?? "unknown"))"
        privilegesLabel.text = "Privileges: \(AuthHelper.isAdmin(user: Auth.auth().currentUser) ? "Admin" : "Standard")"
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
    @IBAction func logout(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            self.dismiss(animated: true, completion: nil)
        } catch (let error) {
            print("Auth sign out failed: \(error)")
        }
    }
    
}

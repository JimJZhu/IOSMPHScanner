//
//  TabBarViewController.swift
//  Scanner
//
//  Created by Jim Zhu on 2018-06-10.
//  Copyright © 2018 Jim. All rights reserved.
//

import UIKit
import IoniconsSwift

class TabBarViewController: UITabBarController {

    //MARK: - Outlets
    @IBOutlet weak var myTabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let firstItem = (self.tabBar.items?[0])! as UITabBarItem
        firstItem.image = Ionicons.iosPricetags.image(30)
        firstItem.selectedImage = Ionicons.iosPricetags.image(30)
        firstItem.title = "Products"
        let secondItem = (self.tabBar.items?[1])! as UITabBarItem
        secondItem.image = Ionicons.gearA.image(30)
        secondItem.selectedImage = Ionicons.gearA.image(30)
        secondItem.title = "Settings"
//        firstItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0)
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

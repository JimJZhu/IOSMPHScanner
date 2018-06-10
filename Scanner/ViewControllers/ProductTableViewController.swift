//
//  ProductTableViewController.swift
//  Scanner
//
//  Created by Jim on 2018-05-16.
//  Copyright © 2018 Jim. All rights reserved.
//

import UIKit
import os.log
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ProductTableViewController: UITableViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var newItemButton: UIBarButtonItem!
    
    //MARK: - Properties
    private var products = [Product]()
    private var filteredProducts = [Product]()
    private let searchController = UISearchController(searchResultsController: nil)
    private var databaseRef: DatabaseReference!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Gets firebase references
        databaseRef = Database.database().reference().child("products")
        
        // Loads products
        loadProducts(from: databaseRef)
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        // Turns off admin features
        newItemButton.isEnabled = AuthHelper.isAdmin(user: Auth.auth().currentUser)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredProducts.count
        }
        return products.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ProductTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ProductTableViewCell else{
            fatalError("Dequeued Cell is not an instance of ProductTableViewCell")
        }
        configureCell(cell: cell, forRowAtIndexPath: indexPath)
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if isFiltering(){
                let toBeDeleted = filteredProducts[indexPath.row]
                var count = 0
                for product in products{
                    if product.id == toBeDeleted.id{
                        products.remove(at: count)
                    }
                    count += 1
                }
                filteredProducts.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }else{
                products.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            let alert = UIAlertController(title: "Deleting Disabled", message: "Item will not be removed from database.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                os_log("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new product.", log: OSLog.default, type: .debug)
        case "ShowDetail":
            guard let productDetailViewController = segue.destination as? ProductViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedProductCell = sender as? ProductTableViewCell else {
                fatalError("Unexpected sender: \(sender ?? "?")")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedProductCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedProduct = isFiltering() ? filteredProducts[indexPath.row] : products[indexPath.row]
            productDetailViewController.product = selectedProduct
            productDetailViewController.dismiss = false
        case "ScanItem":
            os_log("Scanning a new Item.", log: OSLog.default, type: .debug)
            guard let barcodeScannerController = segue.destination.contents as? BarScannerController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            barcodeScannerController.products = products
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "?")")
        }
    }

    //MARK: - Actions
    @IBAction func unwindToProductList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ProductViewController, let product = sourceViewController.product {
            let productRef = self.databaseRef.child(product.id)
            productRef.setValue(product.toAnyObject())
        }
    }
    //MARK: - Private Methods
    private func loadProducts(from ref: DatabaseReference){
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
            self.tableView.reloadData()
        })
    }
    private func configureCell(cell: ProductTableViewCell, forRowAtIndexPath: IndexPath){
        let product = isFiltering() ? filteredProducts[forRowAtIndexPath.row]: products[forRowAtIndexPath.row]
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        cell.nameLabel.text = product.name
        if let exp = product.exp {
            let secondsInDay = 86400.0
            let daysBeforeWarning = 90.0
            let warningDate = Date(timeInterval: daysBeforeWarning*secondsInDay, since: Date())
            if exp < Date() {
                cell.expiryDateLabel.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            } else if exp < warningDate {
                cell.expiryDateLabel.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            } else {
                cell.expiryDateLabel.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            }
            cell.expiryDateLabel.text = "Expires: \(formatter.string(from: exp))"
        }else{
            cell.expiryDateLabel.textColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            cell.expiryDateLabel.text = "Expires:"
        }
        cell.productImageView.sd_setImage(with: product.imageURL, placeholderImage: #imageLiteral(resourceName: "defaultPhoto"), options: [.continueInBackground, .progressiveDownload])
        cell.upcCodeLabel.text = "UPC: \(product.upcEAN ?? "-")"
        cell.asinLabel.text = "ASIN: \(product.asin ?? "-")"
        cell.skuLabel.text = "SKU: \(product.caSKU ?? "-")"
        cell.priceLabel.text = product.highestPrice.priceString
        cell.stockLabel.text = "Stock: \(String(product.stock ?? 0))"
    }

    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    func filterContentForSearchText(_ searchText: String) {
        filteredProducts = products.filter({( product : Product) -> Bool in
            return product.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
}
extension ProductTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
    }
}
extension ProductTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
extension UIViewController {
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? self
        } else {
            return self
        }
    }
}
extension Double{
    var priceString : String{
        return "$\(String(format: "%.2f", self))"
    }
}


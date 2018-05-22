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

class ProductTableViewController: UITableViewController {
    
    //MARK: Properties
    private var products = [Product]()
    private var filteredProducts = [Product]()
    private let searchController = UISearchController(searchResultsController: nil)
    private var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Gets Database reference
        ref = Database.database().reference().child("products")
        // Loads sample products
        loadProducts(from: ref)
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.delegate = self
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
        // #warning Incomplete implementation, return the number of rows
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
            products.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
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
            
            let selectedProduct = products[indexPath.row]
            productDetailViewController.product = selectedProduct
        case "ScanItem":
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier ?? "?")")
        }
    }

    //MARK: Actions
    @IBAction func unwindToProductList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ProductViewController, let product = sourceViewController.product {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing meal.
                products[selectedIndexPath.row] = product
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }else{
                // Add a new meal.
                let newIndexPath = IndexPath(row: products.count, section: 0)
                
                products.append(product)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        }
    }
    
    //MARK: Private Methods
    private func loadProducts(from ref: DatabaseReference){
        ref.observe(.value, with: {(snapshot) in
            for child in snapshot.children{
                guard let productSnapshot = child as? DataSnapshot else{
                    fatalError("Unable to cast as DataSnapshot")
                }
                guard let product = Product(snapshot: productSnapshot) else{
                    fatalError("Unable to instantiate product")
                }
                self.products += [product]
            }
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
                cell.expiryDateLabel.textColor = #colorLiteral(red: 0.521568656, green: 0.1098039225, blue: 0.05098039284, alpha: 1)
            } else if exp < warningDate {
                cell.expiryDateLabel.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
            } else {
                cell.expiryDateLabel.textColor = #colorLiteral(red: 0.1294117719, green: 0.2156862766, blue: 0.06666667014, alpha: 1)
            }
            cell.expiryDateLabel.text = formatter.string(from: exp)
        }else{
            cell.expiryDateLabel.text = "-"
        }
        cell.productImageView.image = product.photo
        cell.upcCodeLabel.text = product.upcEAN ?? "-"
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

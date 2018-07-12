//
//  NewProductViewController.swift
//  Scanner
//
//  Created by Jim on 2018-05-17.
//  Copyright © 2018 Jim. All rights reserved.
//

import UIKit
import os.log
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import SDWebImage

class ProductViewController: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: - Outlets
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var productNameTextField: UITextField!
    @IBOutlet weak var productUPCTextField: UITextField!
    @IBOutlet weak var productCASKUTextField: UITextField!
    @IBOutlet weak var productCOMSKUTextField: UITextField!
    @IBOutlet weak var productASINTextField: UITextField!
    @IBOutlet weak var amazonCAPriceTextField: UITextField!
    @IBOutlet weak var amazonCOMPriceTextField: UITextField!
    @IBOutlet weak var ebayPriceTextField: UITextField!
    @IBOutlet weak var fbaCAPriceTextField: UITextField!
    @IBOutlet weak var fbaCOMPriceTextField: UITextField!
    @IBOutlet weak var fifibabyPriceTextField: UITextField!
    @IBOutlet weak var stockTextField: UITextField!
    @IBOutlet weak var imaplehousePriceTextField: UITextField!
    @IBOutlet weak var maplepetsPriceTextField: UITextField!
    @IBOutlet weak var productExpiryDatePicker: UIDatePicker!
    @IBOutlet weak var expiryDateSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    //MARK: - Properties
    private var loadingScreen: ModalLoadingWindow!
    var product: Product?
    private var databaseRef: DatabaseReference!
    private var storageRef: StorageReference!
    var dismiss: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        productNameTextField.delegate = self
        productUPCTextField.delegate = self
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:))))
        
        if let selectedProduct = product {
            setProductFields(to:selectedProduct)
            // Edit mode off by default
            toggleEditMode(to: false)
        }
        
        // Enable the Save button only if the name text field has a valid name.
        updateSaveButtonState()
        storageRef = Storage.storage().reference().child("products")
        databaseRef = Database.database().reference().child("products")
        loadingScreen = ModalLoadingWindow(frame: self.view.bounds)
        loadingScreen?.title = "Updating..."
        loadingScreen?.subTitle = "Please wait"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        if(textField === productNameTextField){
            updateSaveButtonState()
            navigationItem.title = productNameTextField.text
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        if(textField === productNameTextField){
            saveButton.isEnabled = false
        }
    }
    //MARK: - UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        productImageView.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The cancel button was pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
    }
    //MARK: - Actions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddProductMode = presentingViewController is UITabBarController
        if isPresentingInAddProductMode {
            // Present alert for confirmiation before exiting
            let alert = UIAlertController(title: "Add Item", message: "Are you sure you want to exit Add Item? Changes will not be saved.", preferredStyle: .alert)
            let exitAction = UIAlertAction(title: "Exit", style: .destructive) { (alert: UIAlertAction!) -> Void in
                self.dismiss(animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (alert: UIAlertAction!) -> Void in
            }
            alert.addAction(exitAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion:nil)
        } else if let owningNavigationController = navigationController {
            // Switch to view mode if it toggle mode, otherwise navigate back
            if let title = sender.title, title == "Back" {
                if dismiss {
                    dismiss(animated: true, completion: nil)
                }else{
                    owningNavigationController.popViewController(animated: true)
                }
            } else {
                // Present alert for confirmiation before exiting
                let alert = UIAlertController(title: "Edit Item", message: "Are you sure you want to exit Edit Item? Changes will not be saved.", preferredStyle: .alert)
                let exitAction = UIAlertAction(title: "Exit", style: .destructive) { (alert: UIAlertAction!) -> Void in
                    guard let uneditedProduct = self.product else{
                        fatalError("Selected product does not exist!")
                    }
                    self.setProductFields(to: uneditedProduct)
                    self.toggleEditMode(to: false)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (alert: UIAlertAction!) -> Void in
                }
                alert.addAction(exitAction)
                alert.addAction(cancelAction)
                present(alert, animated: true, completion:nil)
            }
        } else {
            fatalError("The ProductViewController is not inside a navigation controller.")
        }
    }
    @IBAction func selectPhotoFromImageLibrary(_ sender: UITapGestureRecognizer) {
        // Hide the keyboard.
        productUPCTextField.resignFirstResponder()
        productNameTextField.resignFirstResponder()
        productExpiryDatePicker.resignFirstResponder()
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    @IBAction func switchExpiryDateOn(_ sender: UISwitch) {
        updateDatePickerState()
    }
    @IBAction func editOrSave(_ sender: UIBarButtonItem) {
        // Switch between edit mode and save mode
        if let title = sender.title, title == "Edit"{
            toggleEditMode(to: true)
        }else{
            // Present alert for confirmiation before exiting
            let alert = UIAlertController(title: "Save", message: "Are you sure you want to save this item?", preferredStyle: .alert)
            let exitAction = UIAlertAction(title: "Save", style: .destructive) { (alert: UIAlertAction!) -> Void in
                // Processing field text
                let noPriceGiven = "0.00000"
                let name = self.productNameTextField.text ?? "Unnamed"
                let upc = self.productUPCTextField.text
                let exp = self.expiryDateSwitch.isOn ? self.productExpiryDatePicker.date : nil
                let id = self.product?.id ?? UUID().uuidString
                let caSKU = self.productCASKUTextField.text
                let comSKU = self.productCOMSKUTextField.text
                let asin = self.productASINTextField.text
                var amazonCAPrice: Double? = nil
                if let amazonCAPriceText = self.amazonCAPriceTextField.text,
                    amazonCAPriceText != noPriceGiven {
                    amazonCAPrice = Double(amazonCAPriceText)
                }
                var amazonCOMPrice: Double? = nil
                if let amazonCOMPriceText = self.amazonCOMPriceTextField.text,
                    amazonCOMPriceText != noPriceGiven {
                    amazonCOMPrice = Double(amazonCOMPriceText)
                }
                var ebayPrice: Double? = nil
                if let ebayPriceText = self.ebayPriceTextField.text,
                    ebayPriceText != noPriceGiven {
                    ebayPrice = Double(ebayPriceText)
                }
                var fbaCAPrice: Double? = nil
                if let fbaCAPriceText = self.fbaCAPriceTextField.text,
                    fbaCAPriceText != noPriceGiven {
                    fbaCAPrice = Double(fbaCAPriceText)
                }
                var fbaCOMPrice: Double? = nil
                if let fbaCOMPriceText = self.fbaCOMPriceTextField.text,
                    fbaCOMPriceText != noPriceGiven {
                    fbaCOMPrice = Double(fbaCOMPriceText)
                }
                var imaplehousePrice: Double? = nil
                if let imaplehousePriceText = self.imaplehousePriceTextField.text,
                    imaplehousePriceText != noPriceGiven {
                    imaplehousePrice = Double(imaplehousePriceText)
                }
                var fifibabyPrice: Double? = nil
                if let fifibabyPriceText = self.fifibabyPriceTextField.text,
                    fifibabyPriceText != noPriceGiven {
                    fifibabyPrice = Double(fifibabyPriceText)
                }
                var maplepetPrice: Double? = nil
                if let maplepetPriceText = self.maplepetsPriceTextField.text,
                    maplepetPriceText != noPriceGiven {
                    maplepetPrice = Double(maplepetPriceText)
                }
                var stock: Int? = nil
                if let stockText = self.stockTextField.text{
                    stock = Int(stockText)
                }
                
                // Make Thumbnail
                let image = self.productImageView.image?.cgImage
                let width = image?.width / 2
                let height = image?.height / 2
                let bitsPerComponent = image?.bitsPerComponent
                let bytesPerRow = image?.bytesPerRow
                let colorSpace = image?.colorSpace
                let bitmapInfo = image?.bitmapInfo
                let context = CGContext.init(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
                                // Do Image Upload and update image url in DB
                let imageData = UIImageJPEGRepresentation(self.productImageView.image!, 0.8)!
                
                // set upload path
                let filePath = "\(id)"
                let metaData = StorageMetadata()
                metaData.contentType = "image/jpeg"
                
                // Add loading modal
                self.view.addSubview(self.loadingScreen!)
                self.saveButton.isEnabled = false
                self.cancelButton.isEnabled = false
                // Begin upload
                let uploadTask = self.storageRef.child(filePath).putData(imageData, metadata: metaData){(metaData,error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }else{
                        // Retrieve download URL
                        self.storageRef.child(filePath).downloadURL { (url, error) in
                            guard let imageURL = url else {
                                // Uh-oh, an error occurred!
                                os_log("Unable to get download URL!")
                                return
                            }
                            // New product based on fields
                            self.product = Product(name: name, imageURL: imageURL, id: id, upcEAN: upc, exp: exp, amazonCAPrice: amazonCAPrice, amazonCOMPrice: amazonCOMPrice, asin: asin, caSKU: caSKU, comSKU: comSKU, fbaCAPrice: fbaCAPrice, fbaCOMPrice: fbaCOMPrice, ebayPrice: ebayPrice, fifibabyPrice: fifibabyPrice, imaplehousePrice: imaplehousePrice, maplepetPrice: maplepetPrice, stock: stock, ref: nil)
                            self.performSegue(withIdentifier:"saveProduct", sender: self.saveButton)
                        }
                    }
                }
                uploadTask.observe(.success) { snapshot in
                    // Upload completed successfully
                    print("DONE UPLOAD")
                    uploadTask.removeAllObservers()
                    self.loadingScreen?.hide()
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (alert: UIAlertAction!) -> Void in
            }
            alert.addAction(exitAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }
    //MARK: -  Private Methods
    private func updateSaveButtonState(){
        let text = productNameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty && AuthHelper.isAdmin(user: Auth.auth().currentUser)
        
    }
    private func updateDatePickerState(){
        // Turns off and hides date picker if switch is off
        productExpiryDatePicker.isEnabled = expiryDateSwitch.isOn
        productExpiryDatePicker.isHidden = !expiryDateSwitch.isOn
    }
    private func toggleEditMode(to toggleOn: Bool){
        if toggleOn {
            // Enable all controls
            productNameTextField.isEnabled = true
            productImageView.isUserInteractionEnabled = true
            productUPCTextField.isEnabled = true
            productASINTextField.isEnabled = true
            productCOMSKUTextField.isEnabled = true
            productCASKUTextField.isEnabled = true
            amazonCOMPriceTextField.isEnabled = true
            amazonCAPriceTextField.isEnabled = true
            ebayPriceTextField.isEnabled = true
            fbaCOMPriceTextField.isEnabled = true
            fbaCAPriceTextField.isEnabled = true
            imaplehousePriceTextField.isEnabled = true
            fifibabyPriceTextField.isEnabled = true
            maplepetsPriceTextField.isEnabled = true
            stockTextField.isEnabled = true
            expiryDateSwitch.isEnabled = true
            
            // Change look of all controls
            productNameTextField.borderStyle = .roundedRect
            productUPCTextField.borderStyle = .roundedRect
            productASINTextField.borderStyle = .roundedRect
            productCOMSKUTextField.borderStyle = .roundedRect
            productCASKUTextField.borderStyle = .roundedRect
            amazonCOMPriceTextField.borderStyle = .roundedRect
            amazonCAPriceTextField.borderStyle = .roundedRect
            ebayPriceTextField.borderStyle = .roundedRect
            fbaCOMPriceTextField.borderStyle = .roundedRect
            fbaCAPriceTextField.borderStyle = .roundedRect
            imaplehousePriceTextField.borderStyle = .roundedRect
            fifibabyPriceTextField.borderStyle = .roundedRect
            maplepetsPriceTextField.borderStyle = .roundedRect
            stockTextField.borderStyle = .roundedRect
            
            // Set Date picker
            expiryDateSwitch.isEnabled = true
            productExpiryDatePicker.isEnabled = expiryDateSwitch.isOn
            
            // Switch buttons
            saveButton.title = "Save"
            cancelButton.title = "Cancel"
        } else {
            // Disable all controls
            productNameTextField.isEnabled = false
            productImageView.isUserInteractionEnabled = false
            productUPCTextField.isEnabled = false
            productASINTextField.isEnabled = false
            productCOMSKUTextField.isEnabled = false
            productCASKUTextField.isEnabled = false
            amazonCOMPriceTextField.isEnabled = false
            amazonCAPriceTextField.isEnabled = false
            ebayPriceTextField.isEnabled = false
            fbaCOMPriceTextField.isEnabled = false
            fbaCAPriceTextField.isEnabled = false
            imaplehousePriceTextField.isEnabled = false
            fifibabyPriceTextField.isEnabled = false
            maplepetsPriceTextField.isEnabled = false
            stockTextField.isEnabled = false
            productExpiryDatePicker.isEnabled = false
            expiryDateSwitch.isEnabled = false
            
            // Change look of all controls
            productNameTextField.borderStyle = .none
            productUPCTextField.borderStyle = .none
            productASINTextField.borderStyle = .none
            productCOMSKUTextField.borderStyle = .none
            productCASKUTextField.borderStyle = .none
            amazonCOMPriceTextField.borderStyle = .none
            amazonCAPriceTextField.borderStyle = .none
            ebayPriceTextField.borderStyle = .none
            fbaCOMPriceTextField.borderStyle = .none
            fbaCAPriceTextField.borderStyle = .none
            imaplehousePriceTextField.borderStyle = .none
            fifibabyPriceTextField.borderStyle = .none
            maplepetsPriceTextField.borderStyle = .none
            stockTextField.borderStyle = .none
            
            // Switch buttons
            saveButton.title = "Edit"
            cancelButton.title = "Back"
        }
    }
    private func setProductFields(to product: Product){
        print(product.id)
        // Set field values only if in see detail mode
        navigationItem.title = product.name
        productNameTextField.text = product.name
        productImageView.sd_setImage(with: product.imageURL, placeholderImage: #imageLiteral(resourceName: "defaultPhoto"), options: [.continueInBackground, .progressiveDownload])
        productUPCTextField.text = product.upcEAN ?? ""
        productASINTextField.text = product.asin ?? ""
        productCOMSKUTextField.text = product.comSKU ?? ""
        productCASKUTextField.text = product.caSKU ?? ""
        amazonCOMPriceTextField.text = product.amazonCOMPrice.longPriceString
        amazonCAPriceTextField.text = product.amazonCAPrice.longPriceString
        ebayPriceTextField.text = product.ebayPrice.longPriceString
        fbaCOMPriceTextField.text =  product.fbaCOMPrice.longPriceString
        fbaCAPriceTextField.text =  product.fbaCAPrice.longPriceString
        imaplehousePriceTextField.text = product.imaplehousePrice.longPriceString
        fifibabyPriceTextField.text = product.fifibabyPrice.longPriceString
        maplepetsPriceTextField.text =  product.maplepetPrice.longPriceString
        stockTextField.text = String(product.stock ?? 0)
        // Turns off picker if no date is given
        if let exp = product.exp {
            productExpiryDatePicker.date = exp
            productExpiryDatePicker.isHidden = false
            expiryDateSwitch.setOn(true, animated: true)
        }else{
            productExpiryDatePicker.isEnabled = false
            productExpiryDatePicker.isHidden = true
            expiryDateSwitch.setOn(false, animated: true)
        }
    }
}

extension UIImage {
    
    /// Returns a image that fills in newSize
    func resizedImage(newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// Returns a resized image that fits in rectSize, keeping it's aspect ratio
    /// Note that the new image size is not rectSize, but within it.
    func resizedImageWithinRect(rectSize: CGSize) -> UIImage {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height
        
        var resizeFactor = widthFactor
        if size.height > size.width {
            resizeFactor = heightFactor
        }
        
//        let newSize = CGRect.init(size.width/resizeFactor, size.height/resizeFactor)
        let newSize = CGSize.init(width: size.width/resizeFactor, height: size.height/resizeFactor)
        let resized = resizedImage(newSize: newSize)
        return resized
    }
    
}

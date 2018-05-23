//
//  NewProductViewController.swift
//  Scanner
//
//  Created by Jim on 2018-05-17.
//  Copyright © 2018 Jim. All rights reserved.
//

import UIKit
import os.log

class ProductViewController: UIViewController, UITextFieldDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    //MARK: Properties
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
    @IBOutlet weak var imaplehousePriceTextField: UITextField!
    @IBOutlet weak var maplepetsPriceTextField: UITextField!
    @IBOutlet weak var productExpiryDatePicker: UIDatePicker!
    @IBOutlet weak var expiryDateSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    var product: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        productNameTextField.delegate = self
        productUPCTextField.delegate = self
        
        if let selectedProduct = product {
            setProductFields(to:selectedProduct)
            // Edit mode off by default
            toggleEditMode(to: false)
        }
        
        // Enable the Save button only if the name text field has a valid name.
        updateSaveButtonState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UITextFieldDelegate
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
    //MARK: UIImagePickerControllerDelegate
    
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
        let noPriceGiven = "0.00000"
        let name = productNameTextField.text ?? "Unnamed"
        let photo = productImageView.image
        let upc = productUPCTextField.text
        let exp = expiryDateSwitch.isOn ? productExpiryDatePicker.date : nil
        let id = product?.id ?? UUID().uuidString
        let caSKU = productCASKUTextField.text
        let comSKU = productCOMSKUTextField.text
        let asin = productASINTextField.text
        var amazonCAPrice: Double? = nil
        if let amazonCAPriceText = amazonCAPriceTextField.text,
            amazonCAPriceText != noPriceGiven {
            amazonCAPrice = Double(amazonCAPriceText)
        }
        var amazonCOMPrice: Double? = nil
        if let amazonCOMPriceText = amazonCOMPriceTextField.text,
            amazonCOMPriceText != noPriceGiven {
            amazonCOMPrice = Double(amazonCOMPriceText)
        }
        var ebayPrice: Double? = nil
        if let ebayPriceText = ebayPriceTextField.text,
            ebayPriceText != noPriceGiven {
            ebayPrice = Double(ebayPriceText)
        }
        var fbaCAPrice: Double? = nil
        if let fbaCAPriceText = fbaCAPriceTextField.text,
            fbaCAPriceText != noPriceGiven {
            fbaCAPrice = Double(fbaCAPriceText)
        }
        var fbaCOMPrice: Double? = nil
        if let fbaCOMPriceText = fbaCOMPriceTextField.text,
            fbaCOMPriceText != noPriceGiven {
            fbaCOMPrice = Double(fbaCOMPriceText)
        }
        var imaplehousePrice: Double? = nil
        if let imaplehousePriceText = imaplehousePriceTextField.text,
            imaplehousePriceText != noPriceGiven {
            imaplehousePrice = Double(imaplehousePriceText)
        }
        var fifibabyPrice: Double? = nil
        if let fifibabyPriceText = fifibabyPriceTextField.text,
            fifibabyPriceText != noPriceGiven {
            fifibabyPrice = Double(fifibabyPriceText)
        }
        var maplepetPrice: Double? = nil
        if let maplepetPriceText = maplepetsPriceTextField.text,
            maplepetPriceText != noPriceGiven {
            maplepetPrice = Double(maplepetPriceText)
        }
        
        product = Product(name: name, photo: photo, id: id, upcEAN: upc, exp: exp, amazonCAPrice: amazonCAPrice, amazonCOMPrice: amazonCOMPrice, asin: asin, caSKU: caSKU, comSKU: comSKU, fbaCAPrice: fbaCAPrice, fbaCOMPrice: fbaCOMPrice, ebayPrice: ebayPrice, fifibabyPrice: fifibabyPrice, imaplehousePrice: imaplehousePrice, maplepetPrice: maplepetPrice, ref: nil)
    }
    //MARK: Actions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddProductMode = presentingViewController is UITabBarController
        if isPresentingInAddProductMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            // Switch to view mode if it toggle mode, otherwise navigate back
            if let title = sender.title, title == "Back" {
                owningNavigationController.popViewController(animated: true)
            } else {
                guard let uneditedProduct = product else{
                    fatalError("Selected product does not exist!")
                }
                setProductFields(to: uneditedProduct)
                toggleEditMode(to: false)
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
        if let title = sender.title, title == "Edit"{
            toggleEditMode(to: true)
        }else{
            performSegue(withIdentifier:"saveProduct", sender: saveButton)
        }
    }
    //MARK: Private Methods
    private func updateSaveButtonState(){
        let text = productNameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    private func updateDatePickerState(){
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
            expiryDateSwitch.isEnabled = true
            productExpiryDatePicker.isEnabled = expiryDateSwitch.isOn
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
            productExpiryDatePicker.isEnabled = false
            expiryDateSwitch.isEnabled = false
            saveButton.title = "Edit"
            cancelButton.title = "Back"
        }
    }
    private func setProductFields(to product: Product){
        print(product)
        // Set field values if in see detail mode
        navigationItem.title = product.name
        productNameTextField.text = product.name
        productImageView.image = product.photo
        productUPCTextField.text = product.upcEAN ?? "-"
        productASINTextField.text = product.asin ?? "-"
        productCOMSKUTextField.text = product.comSKU ?? "-"
        productCASKUTextField.text = product.caSKU ?? "-"
        amazonCOMPriceTextField.text = String(format:"%.5f", product.amazonCOMPrice ?? "0")
        amazonCAPriceTextField.text = String(format:"%.5f", product.amazonCAPrice ?? "0")
        ebayPriceTextField.text = String(format:"%.5f", product.ebayPrice ?? "0")
        fbaCOMPriceTextField.text = String(format:"%.5f", product.fbaCOMPrice ?? "0")
        fbaCAPriceTextField.text = String(format:"%.5f", product.fbaCAPrice ?? "0")
        imaplehousePriceTextField.text = String(format:"%.5f", product.imaplehousePrice ?? "0")
        fifibabyPriceTextField.text = String(format:"%.5f", product.fifibabyPrice ?? "0")
        maplepetsPriceTextField.text = String(format:"%.5f", product.maplepetPrice ?? "0")
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

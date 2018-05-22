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
//        let name = productNameTextField.text ?? ""
//        let photo = productImageView.image
//        let upc = productUPCTextField.text ?? ""
//        let exp = expiryDateSwitch.isOn ? productExpiryDatePicker.date : nil
//        let id = UUID().uuidString
        // TODO: Fix the addition
//        product = Product(name: name, photo: photo, id: id, upc: upc, exp: exp)
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
    }
    private func toggleEditMode(to toggleOn: Bool){
        if toggleOn {
            // Enable all controls
            productNameTextField.isEnabled = true
            productImageView.isUserInteractionEnabled = true
            productUPCTextField.isEnabled = true
            productExpiryDatePicker.isEnabled = true
            expiryDateSwitch.isEnabled = true
            saveButton.title = "Save"
            cancelButton.title = "Cancel"
        } else {
            // Disable all controls
            productNameTextField.isEnabled = false
            productImageView.isUserInteractionEnabled = false
            productUPCTextField.isEnabled = false
            productExpiryDatePicker.isEnabled = false
            expiryDateSwitch.isEnabled = false
            saveButton.title = "Edit"
            cancelButton.title = "Back"
        }
    }
    private func setProductFields(to product: Product){
        // Set field values if in see detail mode
        navigationItem.title = product.name
        productNameTextField.text = product.name
        productImageView.image = product.photo
        productUPCTextField.text = product.upcEAN ?? "-"
        // Turns off picker if no date is given
        if let exp = product.exp {
            productExpiryDatePicker.date = exp
            expiryDateSwitch.setOn(true, animated: true)
        }else{
            productExpiryDatePicker.isEnabled = false
            expiryDateSwitch.setOn(false, animated: true)
        }
    }
}

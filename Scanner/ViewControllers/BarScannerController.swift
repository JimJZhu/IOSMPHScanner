//
//  BarScannerController.swift
//  Scanner
//
//  Created by Jim on 2018-05-20.
//  Copyright © 2018 Jim. All rights reserved.
//

import UIKit
import AVFoundation

class BarScannerController: UIViewController{
    
    //MARK: - Outlets
    @IBOutlet weak var messageLabel: UILabel!
    
    var products: [Product]?
    var scannedProduct: Product?
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var barCodeFrameView: UIView?
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.upce,
                                      AVMetadataObject.ObjectType.code39,
                                      AVMetadataObject.ObjectType.code39Mod43,
                                      AVMetadataObject.ObjectType.code93,
                                      AVMetadataObject.ObjectType.code128,
                                      AVMetadataObject.ObjectType.ean8,
                                      AVMetadataObject.ObjectType.ean13,
                                      AVMetadataObject.ObjectType.aztec,
                                      AVMetadataObject.ObjectType.pdf417,
                                      AVMetadataObject.ObjectType.itf14,
                                      AVMetadataObject.ObjectType.dataMatrix,
                                      AVMetadataObject.ObjectType.interleaved2of5]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        // Move the message label and top bar to the front
        view.bringSubview(toFront: messageLabel)
        
        // Initialize Bar Code Frame to highlight the Bar code
        barCodeFrameView = UIView()
        
        if let barCodeFrameView = barCodeFrameView {
            barCodeFrameView.layer.borderColor = UIColor.green.cgColor
            barCodeFrameView.layer.borderWidth = 2
            view.addSubview(barCodeFrameView)
            view.bringSubview(toFront: barCodeFrameView)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        guard let productDetailViewController = segue.destination.contents as? ProductViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        productDetailViewController.product = scannedProduct
        productDetailViewController.dismiss = true
    }
    
    // MARK: - Actions
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Helper methods
    func getProduct(decodedURL: String) {
        if presentedViewController != nil {
            return
        }
        var found = false
        for product in products! {
            if product.upcEAN ==  decodedURL {
                found = true
                scannedProduct = product
                let alertPrompt = UIAlertController(title: "\(product.name)", message: "UPC: \(decodedURL) \nStock: \(product.stock ?? 0) \nPrice: $\(product.highestPrice) \nExpiry Date: \(product.expString)", preferredStyle: .actionSheet)
                let confirmAction = UIAlertAction(title: "Go", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    self.performSegue(withIdentifier: "scannedItem", sender: nil)
                })
                
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                alertPrompt.addAction(confirmAction)
                alertPrompt.addAction(cancelAction)
                
                present(alertPrompt, animated: true, completion: nil)
            }
        }
        if !found {
            // Try only 12 digits
            var upc = decodedURL
            upc.remove(at: upc.startIndex)

            for product in products! {
                if product.upcEAN == upc {
                    found = true
                    scannedProduct = product
                    let alertPrompt = UIAlertController(title: "\(product.name)", message: "UPC: \(decodedURL) \nStock: \(product.stock ?? 0) \nPrice: $\(product.highestPrice) \nExpiry Date: \(product.expString)", preferredStyle: .actionSheet)
                    let confirmAction = UIAlertAction(title: "Go", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        self.performSegue(withIdentifier: "scannedItem", sender: nil)
                    })
                    
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                    alertPrompt.addAction(confirmAction)
                    alertPrompt.addAction(cancelAction)
                    
                    present(alertPrompt, animated: true, completion: nil)
                }
            }
            if !found {
                var message = "No product found with the UPC code: \(decodedURL)";
                if decodedURL.count == 13 {
                    message = "No product found with the EAN code: \(decodedURL) or UPC code : \(upc)"
                }
                let alertPrompt = UIAlertController(title: "No Product Found", message: message, preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel, handler: nil)
                
                alertPrompt.addAction(cancelAction)
                
                present(alertPrompt, animated: true, completion: nil)
            }
        }
    }
}

extension BarScannerController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            barCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No Bar code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the Bar code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            barCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                getProduct(decodedURL: metadataObj.stringValue!)
                messageLabel.text = metadataObj.stringValue
            }
        }
    }
    
}

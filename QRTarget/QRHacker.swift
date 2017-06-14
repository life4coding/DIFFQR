//
//  QRHacker.swift
//  QRTarget
//
//  Created by kiwi on 2017/5/23.
//  Copyright © 2017年 DIFF. All rights reserved.
//

import UIKit
import AVFoundation
import CoreImage

// scan from camera


// scan from photo library

//code string to QRCode

//can set functions

// can set animation

//can set completion(open with safari ? copy to copyboard?)


// uiimageview extension: to scan qrcode in image

//wait to do: set function button size dynamically


class QRHackerViewController : UIViewController, AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var session = AVCaptureSession.init()
    
    var didScanComplete:((_ result:String)->Void)?
    var didScanFiald:(()->Void)?
    
    //view life cycle
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        requsetCameraPrivacy()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpCancelScan()
        
    }
    
    //request privacy
    func requsetCameraPrivacy(){
        
        
        let cameraMediaType = AVMediaTypeVideo
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: cameraMediaType)
        
        switch cameraAuthorizationStatus {
            
        // The client is authorized to access the hardware supporting a media type.
        case .authorized:
            
            _ = setUpScanFromCamera()
            // The client is not authorized to access the hardware for the media type. The user cannot change
        // the client's status, possibly due to active restrictions such as parental controls being in place.
        case .restricted:
            break //alertMessageAction("Camera Have Restricted", complete: nil)
            
        // The user explicitly denied access to the hardware supporting a media type for the client.
        case .denied:
            //alertMessageAction("Camera Have Denied, Please Enable in System Settings", complete: nil)
            break
        // Indicates that the user has not yet made a choice regarding whether the client can access the hardware.
        case .notDetermined:
            // Prompting user for the permission to use the camera.
            AVCaptureDevice.requestAccess(forMediaType: cameraMediaType) { [unowned self ] granted in
                if granted {
                    //self.view.setNeedsDisplay()
                    
                    DispatchQueue.main.async {
                        _ = self.setUpScanFromCamera()
                    }
                    
                } else {
                    print("Not granted access to \(cameraMediaType)")
                }
            }
//            break
        }
        
    }
    
    
    func setUpScanFromLibrary(){
        
    }
    
    
    
    func setUpCancelScan(){
        
      //set tool view
        let blurEffect = UIBlurEffect.init(style: .light)
        let blurView = UIVisualEffectView.init(effect: blurEffect)
        
        blurView.frame = CGRect.init(x: 0, y: self.view.bounds.size.height-150, width: self.view.bounds.size.width, height: 150)
        
        self.view.addSubview(blurView)
        
       //set choose from photos
        
    let photoButton = UIButton.init(type: .custom)
    
        photoButton.addTarget(self, action: #selector(openPhotoLibrary), for: .touchUpInside)
    
    photoButton.setImage(UIImage.init(named: "photo"), for: .normal)
    photoButton.bounds.size = CGSize.init(width: 50, height: 50)
    photoButton.frame.origin = CGPoint.init(x: 20, y: blurView.bounds.height/2 - 25)
    blurView.addSubview(photoButton)
    
        
      //set cancel button
        
        let cancelButton = UIButton.init(type: .custom)
        cancelButton.setImage(UIImage.init(named: "back"), for: .normal)
        cancelButton.bounds.size = CGSize.init(width: 50, height: 50)
        cancelButton.frame.origin = CGPoint.init(x: blurView.bounds.width-70 , y: blurView.bounds.height/2 - 25)
        cancelButton.addTarget(self, action: #selector(cancelScan), for: .touchUpInside)
        
        blurView.addSubview(cancelButton)
        
    }
    
    func setUpScanFromCamera(){
        let device = AVCaptureDevice.defaultDevice(withMediaType:AVMediaTypeVideo)
        
        var input : AVCaptureDeviceInput?
        
        do {
            
            input = try AVCaptureDeviceInput.init(device: device)
        }catch _ as NSError {
            //
        }
        
        let output = AVCaptureMetadataOutput.init()
        
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        session.canSetSessionPreset(AVCaptureSessionPresetHigh)
        session.addInput(input)
        session.addOutput(output)
        
        output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        let layer = AVCaptureVideoPreviewLayer.init(session: session)
        layer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        layer?.frame = self.view.frame
        
        self.view.layer.insertSublayer(layer!, at: 0)
        
        session.startRunning()

    }
    
    
    func cancelScan(){
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func openPhotoLibrary(){
        let controller = UIImagePickerController.init()
        controller.sourceType = UIImagePickerControllerSourceType.photoLibrary
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
        
        
    }
    
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        if metadataObjects.count > 0{
            
         let ob = metadataObjects.first as! AVMetadataMachineReadableCodeObject
                
                self.dismiss(animated: true, completion: {
                    
                    self.didScanComplete!(ob.stringValue)
                    
                })
        }
    }
    
    
    //MARK: imagePicker delegate methohs
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage]
        picker.dismiss(animated: true) { 
           let result = QRHacker.scanQRFromPhotos(image as! UIImage)
            
            self.dismiss(animated: true, completion: {
                self.didScanComplete!(result)
                
            })
        }
    }
    
    
    //MARK: generate and scan qr code with picture
    //create qr code image from string
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

class QRHacker:NSObject{
    
    
   static func creatQRCode(withString str:String) -> UIImage{
        
        let data = str.data(using: String.Encoding.utf8,allowLossyConversion: false)
        let filter = CIFilter.init(name: "CIQRCodeGenerator")
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("Q", forKey: "inputCorrectionLevel")
        
        let qrImage = filter?.outputImage
        return UIImage.init(ciImage: qrImage!)
        
    }
    
    
    //scan QR Image from a picture
   static func scanQRFromPhotos(_ image:UIImage) -> String{
        let detector = CIDetector.init(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
    
    
        let results = detector?.features(in: CIImage.init(image: image)!)
    
    if !(results?.isEmpty)!{
        
        let result = results?.first as! CIQRCodeFeature
        
        return result.messageString!
    }else{
        return "nothing"
        }
    }
}

//class AutoDetectImageView: UIImageView{
//    
//    var didScanComplete:((_ result:String)->Void)?
//    
//    
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
//    func longPressTriggered(){
//        
//        let result = QRHacker.scanQRFromPhotos(self.image!)
//        didScanComplete!(result)
//
//    }
//    
//}


//
//  QRHacker.swift
//  QRTarget
//
//  Created by kiwi on 2017/5/23.
//  Copyright © 2017年 DIFF. All rights reserved.
//

import UIKit
import AVFoundation

// scan from camera
// scan from photo library

//code string to QRCode

//can set functions

// can set animation

//can set completion(open with safari ? copy to copyboard?)


// uiimageview extension: to scan qrcode in image

//wait to do: set function button size dynamically


class QRHacker : UIViewController, AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var session = AVCaptureSession.init()
    
    var didScanComplete:((_ result:String)->Void)?
    var didScanFiald:(()->Void)?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
        setUpScanFromCamera()

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        setUpCancelScan()

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
    
    func scanQRFromPhotos(_ image:UIImage){
        let detector = CIDetector.init(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
        
        let results = detector?.features(in: CIImage.init(image: image)!)
        
        let result = results?.first as! CIQRCodeFeature
        
        print("value is : \(String(describing: result.messageString))")

        
    }
    
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        if metadataObjects.count > 0{
            
            let ob = metadataObjects.first
            
            didScanComplete!(String(describing: ob))
            
            print("value is : \(String(describing: ob))")
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage]
        picker.dismiss(animated: true) { 
            self.scanQRFromPhotos(image as! UIImage)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

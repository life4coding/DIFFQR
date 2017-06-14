//
//  ViewController.swift
//  QRTarget
//
//  Created by kiwi on 2017/5/23.
//  Copyright © 2017年 DIFF. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var qrImageView: UIImageView!
    
    
    @IBOutlet weak var inputTextField: UITextField!
    
    
    @IBOutlet weak var outputLabel: UILabel!
    
    
    @IBAction func showQRView(_ sender: Any) {
        
        let vc = QRHacker.init(nibName: nil, bundle: nil)
        
        // self.present(vc, animated: true, completion: nil)
        
        self.show(vc, sender: nil)
    }
    
    @IBAction func generateQRImage(_ sender: Any) {
        
        
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    override func viewDidAppear(_ animated: Bool) {
        
     
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


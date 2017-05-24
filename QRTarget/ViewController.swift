//
//  ViewController.swift
//  QRTarget
//
//  Created by kiwi on 2017/5/23.
//  Copyright © 2017年 DIFF. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
       
        // Do any additional setup after loading the view, typically from a nib.
    }

    
    override func viewDidAppear(_ animated: Bool) {
        
        let vc = QRHacker.init(nibName: nil, bundle: nil)
        
       // self.present(vc, animated: true, completion: nil)
        
        self.show(vc, sender: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


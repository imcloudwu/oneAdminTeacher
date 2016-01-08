//
//  UploadPhotoFunc.swift
//  EPF
//
//  Created by Cloud on 10/14/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class UploadPhotoFunc: UIViewController {
    
    var Delegate : (() -> ())!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.layer.borderWidth = 3.0
        self.view.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.view.layer.cornerRadius = 5
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        Delegate()
    }
}


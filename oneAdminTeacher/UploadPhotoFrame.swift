//
//  UploadPhotoFrame.swift
//  EPF
//
//  Created by Cloud on 10/13/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class UploadPhotoFrame: UIViewController {
    
    @IBOutlet weak var iv: UIImageView!
    
    @IBOutlet weak var CloseBtn: UIButton!
    
    var deleteFromParent : (() -> ())!
    
    var img : UIImage!
    
    var Index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iv.image = img
        
        CloseBtn.layer.masksToBounds = true
        CloseBtn.layer.cornerRadius = CloseBtn.frame.width / 2
        
        self.view.layer.cornerRadius = 5
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        //println(Index)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Delete(sender: AnyObject) {
        deleteFromParent()
    }
    
}

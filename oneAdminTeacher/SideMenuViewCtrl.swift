//
//  SideMenuViewCtrl.swift
//  oneAdminTeacher
//
//  Created by Cloud on 7/10/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class SideMenuViewCtrl: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var background = UIImageView(image: UIImage(named: "sidebackground.jpg"))
        background.frame = self.view.bounds
        background.contentMode = UIViewContentMode.ScaleToFill
        self.view.insertSubview(background, atIndex: 0)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func Btn1(sender: AnyObject) {
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("ClassQuery") as! UIViewController
        
        ChangeContentView(nextView)
    }
    
    @IBAction func Btn2(sender: AnyObject) {
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("AdvanceQuery") as! UIViewController
        
        ChangeContentView(nextView)
    }
    
    @IBAction func Btn3(sender: AnyObject) {
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("Message") as! UIViewController
        
        ChangeContentView(nextView)
    }
    
}

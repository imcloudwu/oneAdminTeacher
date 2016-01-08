//
//  CreateAlbumViewCtrl.swift
//  oneAdminTeacher
//
//  Created by Cloud on 1/4/16.
//  Copyright © 2016 ischool. All rights reserved.
//

import UIKit

class CreateAlbumViewCtrl: UIViewController {
    
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var groupBtn: UIButton!
    
    @IBOutlet weak var saveBtn: UIButton!
    
    var _currentGroup : GroupItem!
    
    
    @IBAction func groupSelect(sender: AnyObject) {
        
        let ask = UIAlertController(title: "choose a group", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        ask.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        
        for g in Global.TeacherGroups{
            
            ask.addAction(UIAlertAction(title: g.GroupName, style: UIAlertActionStyle.Default, handler: { (act) -> Void in
                
                self.groupBtn.setTitle(g.GroupName, forState: UIControlState.Normal)
                self._currentGroup = g
            }))
        }
        
        self.presentViewController(ask, animated: true, completion: nil)

    }
    
    @IBAction func save(sender: AnyObject) {
        
        if let group = _currentGroup , let name = textField.text where !name.isEmpty{
            
            let con = GetCommonConnect(group.DSNS)
            
            var err : DSFault!
            
            con.SendRequest("album.AddAlbum", bodyContent: "<Request><album><Field><AlbumName>\(name)</AlbumName><RefGroupId>\(group.GroupId)</RefGroupId></Field></album></Request>", &err)
            
            self.navigationController?.popViewControllerAnimated(true)
        }
        else{
            
            let alert = UIAlertController(title: "相簿名稱或儲存位置不可為空白", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Cancel, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveBtn.layer.cornerRadius = 5
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
}

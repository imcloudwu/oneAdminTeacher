//
//  AdvanceInfoViewCtrl.swift
//  oneAdminTeacher
//
//  Created by Cloud on 6/30/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class AdvanceInfoViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var _funcItem = ["缺曠查詢","獎懲查詢","評量成績查詢","學期成績查詢"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Trash, target: self, action: "DeleteStudent")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "SelectStudent")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        ResetViewTitle()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _funcItem.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell = tableView.dequeueReusableCellWithIdentifier("funcCell") as? UITableViewCell
        
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "funcCell")
        }
        
        cell!.textLabel?.text = _funcItem[indexPath.row]
        cell!.imageView?.image = UIImage(named: "Phone-32.png")
        //cell.detailTextLabel?.text = _funcItem[indexPath.row]
        return cell!
    }
    
    func ResetViewTitle(){
        if Global.CurrentStudent == nil && Global.Students.count > 0{
            Global.CurrentStudent = Global.Students[0]
        }
        
        if Global.CurrentStudent == nil{
            self.navigationItem.title = "尚未選擇任何學生"
        }
        else{
            self.navigationItem.title = Global.CurrentStudent.Name
        }
    }
    
    func DeleteStudent(){
        let actionSheet = UIAlertController(title: "請選擇一位學生", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        for stu in Global.Students{
            let action = UIAlertAction(title: stu.DSNS + "_" + stu.Name, style: UIAlertActionStyle.Default, handler: { (act) -> Void in
                Global.DeleteStudent(stu)
                self.ResetViewTitle()
            })
            
            actionSheet.addAction(action)
        }
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func SelectStudent(){
        let actionSheet = UIAlertController(title: "請選擇一位學生", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        for stu in Global.Students{
            let action = UIAlertAction(title: stu.DSNS + "_" + stu.Name, style: UIAlertActionStyle.Default, handler: { (act) -> Void in
                Global.CurrentStudent = stu
                self.ResetViewTitle()
            })
            
            actionSheet.addAction(action)
        }
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    
}
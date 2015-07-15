//
//  ClassViewCtrl.swift
//  oneAdminTeacher
//
//  Created by Cloud on 7/10/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//


import UIKit

class ClassViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progress: UIProgressView!
    
    var progressTimer : ProgressTimer!
    var refreshControl : UIRefreshControl!
    
    var _ClassList = [ClassItem]()
    
    var sideMenuBtn : UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: "ReloadData", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        
        sideMenuBtn = UIBarButtonItem(image: UIImage(named: "Menu Filled-25.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "ToggleSideMenu")
        self.navigationItem.leftBarButtonItem = sideMenuBtn
        
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationItem.title = "我的班級"
        
        progressTimer = ProgressTimer(progressBar: progress)
        
        if Global.ClassList != nil{
            _ClassList = Global.ClassList
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if Global.ClassList == nil{
            GetMyClassList()
        }
    }
    
    func ToggleSideMenu(){
        var app = UIApplication.sharedApplication().delegate as! AppDelegate
        
        app.centerContainer?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    func ReloadData(){
        GetMyClassList()
        self.refreshControl.endRefreshing()
    }
    
    func GetMyClassList() {
        
        var tmpList = [ClassItem]()
        
        progressTimer.StartProgress()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            for dsns in Global.DsnsList{
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                    
                    var con = Connection()
                    CommonConnect(dsns.AccessPoint, con, self)
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        tmpList += self.GetClassData(con)
                        self._ClassList = tmpList
                        Global.ClassList = tmpList
                        self.tableView.reloadData()
                    })
                })
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                self.progressTimer.StopProgress()
            })
        })
    }
    
    func GetClassData(con:Connection) -> [ClassItem]{
        
        var err : DSFault!
        var nserr : NSError?
        
        var retVal = [ClassItem]()
        
        var rsp = con.sendRequest("main.GetMyTutorClasses", bodyContent: "", &err)
        
        if err != nil{
            //ShowErrorAlert(self,err,nil)
            return retVal
        }
        
        let xml = AEXMLDocument(xmlData: rsp.dataValue, error: &nserr)
        
        if let classes = xml?.root["ClassList"]["Class"].all {
            for cls in classes{
                let ClassID = cls["ClassID"].stringValue
                let ClassName = cls["ClassName"].stringValue
                let GradeYear = cls["GradeYear"].stringValue.toInt() ?? 0
                
                retVal.append(ClassItem(ID: ClassID, ClassName: con.accessPoint + "_" + ClassName, AccessPoint: con.accessPoint, GradeYear: GradeYear))
            }
        }
        
        return retVal
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _ClassList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("ClassCell") as! ClassCell
        cell.ClassName.text = _ClassList[indexPath.row].ClassName
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("StudentViewCtrl") as! StudentViewCtrl
        nextView.ClassData = _ClassList[indexPath.row]
        self.navigationController?.pushViewController(nextView, animated: true)
    }
}

struct ClassItem{
    var ID : String
    var ClassName : String
    var AccessPoint : String
    var GradeYear : Int
}

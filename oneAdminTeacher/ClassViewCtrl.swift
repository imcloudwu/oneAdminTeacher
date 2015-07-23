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
    
    //var progressTimer : ProgressTimer!
    var refreshControl : UIRefreshControl!
    
    var _ClassList = [ClassItem]()
    
    var sideMenuBtn : UIBarButtonItem!
    
    var DsnsResult = [String:Bool]()
    
    let redColor = UIColor(red: 244 / 255, green: 67 / 255, blue: 54 / 255, alpha: 1)
    let blueColor = UIColor(red: 33 / 255, green: 150 / 255, blue: 243 / 255, alpha: 1)
    
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
        self.navigationController?.interactivePopGestureRecognizer.enabled = false
        
        //progressTimer = ProgressTimer(progressBar: progress)
        
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
        
        self.progress.hidden = false
        
        var tmpList = [ClassItem]()
        
        DsnsResult.removeAll(keepCapacity: false)
        for dsns in Global.DsnsList{
            DsnsResult[dsns.Name] = false
        }
        
        var percent : Float = 1 / Float(DsnsResult.count)
        
        self.progress.progress = 0
        
        for dsns in Global.DsnsList{
            
            //self.progressTimer.StartProgress()
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                
                var con = Connection()
                CommonConnect(dsns.AccessPoint, con, self)
                tmpList += self.GetData(con)
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.DsnsResult[dsns.Name] = true
                    //self.progressTimer.StopProgress()
                    self.progress.progress += percent
                    
                    if self.AllDone(){
                        self.progress.hidden = true
                    }
                    
                    self._ClassList = tmpList
                    Global.ClassList = tmpList
                    self.tableView.reloadData()
                })
            })
        }
        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
//            
//            for dsns in Global.DsnsList{
//                
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
//                    
//                    var con = Connection()
//                    CommonConnect(dsns.AccessPoint, con, self)
//                    tmpList += self.GetClassData(con)
//                    
//                    dispatch_async(dispatch_get_main_queue(), {
//                        
//                        self._ClassList = tmpList
//                        Global.ClassList = tmpList
//                        self.tableView.reloadData()
//                    })
//                })
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), {
//                self.progressTimer.StopProgress()
//            })
//        })
    }
    
    func GetData(con:Connection) -> [ClassItem]{
        
        var retVal = [ClassItem]()
        
        retVal += GetClassData(con)
        retVal += GetCourseData(con)
        
        return retVal
    }
    
    func GetClassData(con:Connection) -> [ClassItem]{
        
        var retVal = [ClassItem]()
        
        var err : DSFault!
        var nserr : NSError?
        
        var rsp = con.sendRequest("main.GetMyTutorClasses", bodyContent: "", &err)
        
        if err != nil{
            //ShowErrorAlert(self,err,nil)
            return retVal
        }
        
        var xml = AEXMLDocument(xmlData: rsp.dataValue, error: &nserr)
        
        retVal.append(ClassItem(ID: "header", ClassName: GetSchoolName(con), AccessPoint: "", GradeYear: 0, Major: ""))
        
        if let classes = xml?.root["ClassList"]["Class"].all {
            for cls in classes{
                let ClassID = cls["ClassID"].stringValue
                let ClassName = cls["ClassName"].stringValue
                let GradeYear = cls["GradeYear"].stringValue.toInt() ?? 0
                
                retVal.append(ClassItem(ID: ClassID, ClassName: ClassName, AccessPoint: con.accessPoint, GradeYear: GradeYear, Major: "班導師"))
            }
        }
        
        return retVal
    }
    
    func GetCourseData(con:Connection) -> [ClassItem]{
        
        var retVal = [ClassItem]()
        
        var err : DSFault!
        var nserr : NSError?
        
        var schoolYear = ""
        var semester = ""
        
        //GetSemester first
        var rsp = con.sendRequest("main.GetCurrentSemester", bodyContent: "", &err)
        
        if err != nil{
            //ShowErrorAlert(self,err,nil)
            return retVal
        }
        
        var xml = AEXMLDocument(xmlData: rsp.dataValue, error: &nserr)
        
        if let sy = xml?.root["Response"]["SchoolYear"].first?.stringValue{
            schoolYear = sy
        }
        
        if let sm = xml?.root["Response"]["Semester"].first?.stringValue{
            semester = sm
        }
        
        //GetCourseData
        rsp = con.sendRequest("main.GetMyCourses", bodyContent: "<Request><All></All><SchoolYear>\(schoolYear)</SchoolYear><Semester>\(semester)</Semester></Request>", &err)
        
        if err != nil{
            //ShowErrorAlert(self,err,nil)
            return retVal
        }
        
        xml = AEXMLDocument(xmlData: rsp.dataValue, error: &nserr)
        
        if let classes = xml?.root["ClassList"]["Class"].all {
            for cls in classes{
                let CourseID = cls["CourseID"].stringValue
                let CourseName = cls["CourseName"].stringValue
                let GradeYear = cls["GradeYear"].stringValue.toInt() ?? 0
                
                retVal.append(ClassItem(ID: CourseID, ClassName: CourseName, AccessPoint: con.accessPoint, GradeYear: GradeYear, Major: "授課老師"))
            }
        }
        
        return retVal
    }
    
    //new solution
    func GetSchoolName(con:Connection) -> String{
        
        var schoolName = ""
        
        //encode成功呼叫查詢
        if let encodingName = con.accessPoint.UrlEncoding{
            
            var data = HttpClient.Get("http://dsns.1campus.net/campusman.ischool.com.tw/config.public/GetSchoolList?content=%3CRequest%3E%3CMatch%3E\(encodingName)%3C/Match%3E%3CPagination%3E%3CPageSize%3E10%3C/PageSize%3E%3CStartPage%3E1%3C/StartPage%3E%3C/Pagination%3E%3C/Request%3E")
            
            if let rsp = data{
                
                //println(NSString(data: rsp, encoding: NSUTF8StringEncoding))
                
                var nserr : NSError?
                
                let xml = AEXMLDocument(xmlData: rsp, error: &nserr)
                
                if let name = xml?.root["Response"]["School"]["Title"].stringValue{
                    schoolName = name
                }
            }
        }
        
        return schoolName
    }
    
    func AllDone() -> Bool{
        
        for dsns in DsnsResult{
            if !dsns.1{
                return false
            }
        }
        
        return true
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _ClassList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let data = _ClassList[indexPath.row]
        
        if data.ID == "header"{
            var cell = tableView.dequeueReusableCellWithIdentifier("summaryItem") as? UITableViewCell
            
            if cell == nil{
                cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "summaryItem")
                cell?.backgroundColor = UIColor(red: 238 / 255, green: 238 / 255, blue: 238 / 255, alpha: 1)
            }
            
            cell?.textLabel?.text = data.ClassName
            return cell!
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ClassCell") as! ClassCell
        cell.ClassName.text = data.ClassName
        cell.Major.text = data.Major
        
        if data.Major == "班導師"{
            cell.ClassIcon.backgroundColor = redColor
        }
        else{
            cell.ClassIcon.backgroundColor = blueColor
        }
        
        //字串擷取
        if (data.ClassName as NSString).length > 0{
            let subString = (data.ClassName as NSString).substringToIndex(1)
            cell.ClassIcon.text = subString
        }
        else{
            cell.ClassIcon.text = ""
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        let data = _ClassList[indexPath.row]
        
        if data.ID != "header"{
            let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("StudentViewCtrl") as! StudentViewCtrl
            nextView.ClassData = _ClassList[indexPath.row]
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if _ClassList[indexPath.row].ID == "header"{
            return 30
        }
        
        return 60
    }
}

struct ClassItem{
    var ID : String
    var ClassName : String
    var AccessPoint : String
    var GradeYear : Int
    var Major : String
}

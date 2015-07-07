//
//  FirstViewController.swift
//  oneAdminTeacher
//
//  Created by Cloud on 6/12/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class MenuViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var progressTimer : ProgressTimer!
    
    var alertController: UIAlertController!
    
    var Timer : NSTimer!
    
    var _currentClassName = "全部列表"
    var _studentData = [Student]()
    var _displayData = [Student]()
    var _classData = [ClassItem]()
    
    var _con = Connection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //將本機catch讀出
        for student in CoreData.LoadCatchData(){
            if !contains(Global.Students, student){
                Global.Students.append(student)
            }
        }
        
        progressTimer = ProgressTimer(progressBar: progressBar)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Reply, target: self, action: "ChangeSchoolServer")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "SelectClass")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        //Connect()
        
        CommonConnect(Global.CurrentDsns.AccessPoint, self._con, self)
        
        _classData = GetClassData()
        
        alertController = UIAlertController(title: "", message: "請選擇班級", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alertController.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        for cls in _classData{
            alertController.addAction(UIAlertAction(title: cls.ClassName, style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.SetDataToTableView(cls)
            }))
        }
        
        if _classData.count > 0{
            self.SetDataToTableView(_classData[0])
        }
        
//        let confirmClosure: ((UIAlertAction!) -> Void)! = { action in
//            
//            self._currentClassName = action.title
//            self._displayData.removeAll(keepCapacity: false)
//            
//            for data in self._data {
//                if data.ClassName == self._currentClassName || self._currentClassName == "全部列表"{
//                    self._displayData.append(data)
//                }
//            }
//            
//            self.tableView.reloadData()
//        }
        
        
        
//        alertController.addAction(UIAlertAction(title: "自訂查詢", style: UIAlertActionStyle.Default){ ((UIAlertAction!)) -> Void in
//            
//            let inputView = UIAlertController(title: "", message: "請輸入關鍵字", preferredStyle: UIAlertControllerStyle.Alert)
//            inputView.addTextFieldWithConfigurationHandler(nil)
//            inputView.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
//                let textfield = inputView.textFields?.first as! UITextField
//                let name = textfield.text
//                self._currentClassName = action.title
//                self._displayData.removeAll(keepCapacity: false)
//                
//                for data in self._data {
//                    let s_name = data.Name.lowercaseString
//                    
//                    if let result = s_name.rangeOfString(name.lowercaseString){
//                        self._displayData.append(data)
//                    }
//                }
//                
//                self.tableView.reloadData()
//            }))
//            
//            self.presentViewController(inputView, animated: true, completion: nil)
//        })
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func SelectClass() {
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func ChangeSchoolServer(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _displayData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("studentCell") as! StudentCell
        cell.Photo.image = _displayData[indexPath.row].Photo
        cell.Label1.text = "姓名: \(_displayData[indexPath.row].Name)"
        cell.Label2.text = "學號: \(_displayData[indexPath.row].StudentNumber)   座號: \(_displayData[indexPath.row].SeatNo) "
        cell.Label3.text = "姓別: \(_displayData[indexPath.row].Gender)"
        cell.Label4.text = "監護人: \(_displayData[indexPath.row].CustodianName)"
        return  cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return _currentClassName
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("studentInfoViewCtrl") as! StudentInfoViewCtrl
        nextView.StudentData = _displayData[indexPath.row]
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func SetDataToTableView(cls:ClassItem){
        
        progressTimer.StartProgress()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            self._currentClassName = cls.ClassName
            self._studentData = self.GetStudentData(cls.ID)
            self._displayData = self._studentData
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                self.progressTimer.StopProgress()
            })
        })
    }
    
//    func Connect(){
//        
//        var err: DSFault!
//        
//        _con.connect(Global.CurrentDsns.AccessPoint, "ischool.teacher.app", SecurityToken.createOAuthToken(Global.AccessToken), &err)
//        
//        if err != nil{
//            ShowErrorAlert(self,err,nil)
//        }
//    }
    
    func GetClassData() -> [ClassItem]{
        
        var err : DSFault!
        var nserr : NSError?
        
        var retVal = [ClassItem]()
        
        var rsp = _con.sendRequest("main.GetMyTutorClasses", bodyContent: "", &err)
        
        if err != nil{
            ShowErrorAlert(self,err,nil)
            return retVal
        }
        
        let xml = AEXMLDocument(xmlData: rsp.dataValue, error: &nserr)
        
        if let classes = xml?.root["ClassList"]["Class"].all {
            for cls in classes{
                let ClassID = cls["ClassID"].stringValue
                let ClassName = cls["ClassName"].stringValue
                let GradeYear = cls["GradeYear"].stringValue.toInt() ?? 0
                
                retVal.append(ClassItem(ID: ClassID, ClassName: ClassName, GradeYear: GradeYear))
            }
        }
        
        return retVal
    }
    
    func GetStudentData(classID:String) -> [Student]{
        
        var err : DSFault!
        var nserr : NSError?
        
        var retVal = [Student]()
        
        var rsp = _con.sendRequest("main.GetClassStudents", bodyContent: "<Request><All></All><ClassID>\(classID)</ClassID></Request>", &err)
        
        //println(rsp)
        
        if err != nil{
            ShowErrorAlert(self,err,nil)
            return retVal
        }
        
        let xml = AEXMLDocument(xmlData: rsp.dataValue, error: &nserr)
        
        if let students = xml?.root["Response"]["Student"].all {
            for stu in students{
                //println(stu.xmlString)
                let studentID = stu["StudentID"].stringValue
                let className = stu["ClassName"].stringValue
                let studentName = stu["StudentName"].stringValue
                let seatNo = stu["SeatNo"].stringValue
                let studentNumber = stu["StudentNumber"].stringValue
                let gender = stu["Gender"].stringValue
                let mailingAddress = stu["MailingAddress"].xmlString
                let permanentAddress = stu["PermanentAddress"].xmlString
                let contactPhone = stu["ContactPhone"].stringValue
                let permanentPhone = stu["PermanentPhone"].stringValue
                let custodianName = stu["CustodianName"].stringValue
                let fatherName = stu["FatherName"].stringValue
                let motherName = stu["MotherName"].stringValue
                let freshmanPhoto = GetImageFromBase64String(stu["FreshmanPhoto"].stringValue, defaultImg: UIImage(named: "User-100.png"))
                
                let stuItem = Student(DSNS: Global.CurrentDsns.AccessPoint,ID: studentID, ClassName: className, Name: studentName, SeatNo: seatNo, StudentNumber: studentNumber, Gender: gender, MailingAddress: mailingAddress, PermanentAddress: permanentAddress, ContactPhone: contactPhone, PermanentPhone: permanentPhone, CustodianName: custodianName, FatherName: fatherName, MotherName: motherName, Photo: freshmanPhoto)
                
                retVal.append(stuItem)
            }
        }
        
        retVal.sort{ $0.SeatNo.toInt() < $1.SeatNo.toInt() }

        return retVal
    }
    
    func GetImageFromBase64String(base64String:String,defaultImg:UIImage?) -> UIImage?{
        
        var decodedimage : UIImage?
        
        if let decodedData = NSData(base64EncodedString: base64String, options: NSDataBase64DecodingOptions(rawValue: 0)){
            decodedimage = UIImage(data: decodedData)
        }
        
        return decodedimage ?? defaultImg
    }
    
}

struct ClassItem{
    var ID : String!
    var ClassName : String!
    var GradeYear : Int!
}

struct Student : Equatable{
    var DSNS : String!
    var ID : String!
    var ClassName : String!
    var Name : String!
    var SeatNo : String!
    var StudentNumber : String!
    var Gender : String!
    var MailingAddress : String!
    var PermanentAddress : String!
    var ContactPhone : String!
    var PermanentPhone : String!
    var CustodianName : String!
    var FatherName : String!
    var MotherName : String!
    var Photo : UIImage!
}

func ==(lhs: Student, rhs: Student) -> Bool {
    return lhs.DSNS == rhs.DSNS && lhs.ID == rhs.ID
}


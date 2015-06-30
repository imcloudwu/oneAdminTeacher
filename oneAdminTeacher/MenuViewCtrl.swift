//
//  FirstViewController.swift
//  oneAdminTeacher
//
//  Created by Cloud on 6/12/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit
import CoreData

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
        
        progressTimer = ProgressTimer(progressBar: progressBar)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Reply, target: self, action: "ChangeSchoolServer")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        Connect()
        
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
    
    @IBAction func SelectClass(sender: AnyObject) {
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
    
    func SaveCatchData(student:Student,forceInsert:Bool) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Student")
        fetchRequest.predicate = NSPredicate(format: "name=%@", student.Name)
        
        var needInsert = true
        
        if let fetchResults = managedObjectContext.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
            if fetchResults.count != 0 {
                
                var managedObject = fetchResults[0]
                //managedObject.setValue(student.Name, forKey: "name")
                managedObject.setValue(student.ClassName, forKey: "class_name")
                managedObject.setValue(student.ContactPhone, forKey: "phone")
                managedObject.setValue(UIImagePNGRepresentation(student.Photo), forKey: "photo")
                
                needInsert = false
            }
        }
        
        if needInsert || forceInsert{
            let myEntityDescription = NSEntityDescription.entityForName("Student", inManagedObjectContext: managedObjectContext)
            
            let myObject = NSManagedObject(entity: myEntityDescription!, insertIntoManagedObjectContext: managedObjectContext)
            
            myObject.setValue(student.Name, forKey: "name")
            myObject.setValue(student.ClassName, forKey: "class_name")
            myObject.setValue(student.ContactPhone, forKey: "phone")
            myObject.setValue(UIImagePNGRepresentation(student.Photo), forKey: "photo")
        }
        
        managedObjectContext.save(nil)
    }
    
    func LoadCatchData(){
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: "Student")
        
        var error: NSError?
        
        let results = managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]
        
        for obj in results {
            let name = obj.valueForKey("name") as! String
            let class_name = obj.valueForKey("class_name") as! String
            let phone = obj.valueForKey("phone") as! String
            let photo = obj.valueForKey("photo") as! NSData
            
            //_studentData.append(Student(Photo: UIImage(data: photo), ClassName : class_name, Name: name, Phone: phone))
        }
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
    
    func Connect(){
        
        var err: DSFault!
        
        _con.connect(Global.CurrentDsns.AccessPoint, "ischool.teacher.app", SecurityToken.createOAuthToken(Global.AccessToken), &err)
        
        if err != nil{
            ShowErrorAlert(err)
        }
    }
    
    func GetClassData() -> [ClassItem]{
        
        var err : DSFault!
        var nserr : NSError?
        
        var retVal = [ClassItem]()
        
        var rsp = _con.sendRequest("main.GetMyTutorClasses", bodyContent: "", &err)
        
        if err != nil{
            ShowErrorAlert(err)
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
            ShowErrorAlert(err)
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
    
    func ShowErrorAlert(err:DSFault){
        let alert = UIAlertController(title: "錯誤", message: err.message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
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


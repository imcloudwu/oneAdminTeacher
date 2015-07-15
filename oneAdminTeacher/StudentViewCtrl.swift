//
//  FirstViewController.swift
//  oneAdminTeacher
//
//  Created by Cloud on 6/12/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class StudentViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var progressTimer : ProgressTimer!
    
    //var Timer : NSTimer!
    
    var _studentData = [Student]()
    var _displayData = [Student]()
    var ClassData : ClassItem!
    
    var _con = Connection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //將本機catch讀出
//        for student in CoreData.LoadCatchData(){
//            if !contains(Global.Students, student){
//                Global.Students.append(student)
//            }
//        }
        
        progressTimer = ProgressTimer(progressBar: progressBar)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        self.navigationItem.title = ClassData.ClassName
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if _displayData.count == 0{
            SetDataToTableView()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("StudentDetailViewCtrl") as! StudentDetailViewCtrl
        nextView.StudentData = _displayData[indexPath.row]
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func SetDataToTableView(){
        
        progressTimer.StartProgress()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            CommonConnect(self.ClassData.AccessPoint, self._con, self)
            self._studentData = self.GetStudentData()
            self._displayData = self._studentData
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                self.progressTimer.StopProgress()
            })
        })
    }
    
    func GetStudentData() -> [Student]{
        
        var err : DSFault!
        var nserr : NSError?
        
        var retVal = [Student]()
        
        var rsp = _con.sendRequest("main.GetClassStudents", bodyContent: "<Request><All></All><ClassID>\(ClassData.ID)</ClassID></Request>", &err)
        
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
                
                let stuItem = Student(DSNS: ClassData.AccessPoint,ID: studentID, ClassName: className, Name: studentName, SeatNo: seatNo, StudentNumber: studentNumber, Gender: gender, MailingAddress: mailingAddress, PermanentAddress: permanentAddress, ContactPhone: contactPhone, PermanentPhone: permanentPhone, CustodianName: custodianName, FatherName: fatherName, MotherName: motherName, Photo: freshmanPhoto)
                
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


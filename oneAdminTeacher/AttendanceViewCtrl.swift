//
//  AttendanceViewCtrl.swift
//  oneAdminTeacher
//
//  Created by Cloud on 7/1/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class AttendanceViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progress: UIProgressView!
    
    var progressTimer:ProgressTimer!
    
    var _data = [AttendanceItem]()
    var _displayData = [AttendanceItem]()
    var _Semesters = [SemesterItem]()
    var _CurrentSemester : SemesterItem!
    
    var StudentData : Student!
    
    var _con = Connection()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressTimer = ProgressTimer(progressBar: progress)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "ChangeSemester")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if self._data.count > 0{
            return
        }
        
        progressTimer.StartProgress()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            CommonConnect(self, self._con)
            //self.Connect()
            self._data = self.GetAttendanceData()
            
            for data in self._data{
                let semester = SemesterItem(SchoolYear: data.SchoolYear, Semester: data.Semester)
                if !contains(self._Semesters, semester){
                    self._Semesters.append(semester)
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                if self._Semesters.count > 0{
                    self._Semesters.sort({$0 > $1})
                    self.SetDataToTableView(self._Semesters[0])
                }
                
                self.progressTimer.StopProgress()
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    func GetAttendanceData() -> [AttendanceItem]{
        
        var err : DSFault!
        var nserr : NSError?
        
        var retVal = [AttendanceItem]()
        
        var rsp = _con.sendRequest("attendance.GetStudentAttendance", bodyContent: "<Request><RefStudentId>\(StudentData.ID)</RefStudentId></Request>", &err)
        
        if err != nil{
            ShowErrorAlert(self,err,nil)
            return retVal
        }
        
        let xml = AEXMLDocument(xmlData: rsp.dataValue, error: &nserr)
        
        if let attendances = xml?.root["Response"]["Attendance"].all {
            for attendance in attendances{
                let occurDate = attendance.attributes["OccurDate"] as! String
                let schoolYear = attendance.attributes["SchoolYear"] as! String
                let semester = attendance.attributes["Semester"] as! String
                
                if let periods = attendance["Detail"]["Period"].all {
                    for period in periods{
                        let absenceType = period.attributes["AbsenceType"] as! String
                        let periodName = period.stringValue
                        
                        let item = AttendanceItem(OccurDate: occurDate, SchoolYear: schoolYear, Semester: semester, AbsenceType: absenceType, Period: periodName, Value: 1)
                        
                        retVal.append(item)
                    }
                }
                
            }
        }
        
        return retVal
    }
    
    func SetDataToTableView(semester:SemesterItem){
        
        self._CurrentSemester = semester
        var newData = [AttendanceItem]()
        var tmpData = [String:AttendanceItem]()
        
        for data in self._data{
            if data.SchoolYear == semester.SchoolYear && data.Semester == semester.Semester{
                
                let key = data.OccurDate + "_" + data.AbsenceType
                
                if tmpData[key] == nil{
                    tmpData[key] = data
                }
                else{
                    tmpData[key]?.Period += ",\(data.Period)"
                    tmpData[key]?.Value += data.Value
                }
            }
        }
        
        for tmp in tmpData{
            newData.append(tmp.1)
        }
        
        newData.sort{$0.OccurDate > $1.OccurDate}
        
        var sum = [String:Int]()
        
        for data in newData{
            if sum[data.AbsenceType] == nil{
                sum[data.AbsenceType] = 0
            }
            
            sum[data.AbsenceType]? += data.Value
        }
        
        var total = 0
        for s in sum{
            var sumData = AttendanceItem(OccurDate: s.0, SchoolYear: "", Semester: "", AbsenceType: "summaryItem", Period: "", Value: s.1)
            newData.insert(sumData, atIndex: 0)
            total += s.1
        }
        
        newData.insert(AttendanceItem(OccurDate: "總計", SchoolYear: "", Semester: "", AbsenceType: "summaryItem", Period: "", Value: total), atIndex: 0)
        
        self._displayData = newData
        
        self.tableView.reloadData()
    }
    
    func ChangeSemester(){
        let actionSheet = UIAlertController(title: "請選擇學年度學期", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        for semeter in _Semesters{
            actionSheet.addAction(UIAlertAction(title: semeter.Description, style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.SetDataToTableView(semeter)
            }))
        }
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _displayData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        if _displayData[indexPath.row].AbsenceType == "summaryItem"{
            var cell = tableView.dequeueReusableCellWithIdentifier("summaryItem") as? UITableViewCell
            
            if cell == nil{
                cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "summaryItem")
                cell?.textLabel?.textColor = UIColor(red: 19/255, green: 144/255, blue: 255/255, alpha: 1)
            }
            
            cell!.textLabel?.text = _displayData[indexPath.row].OccurDate
            cell!.detailTextLabel?.text = "\(_displayData[indexPath.row].Value)"
            
            return cell!
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("attendanceItemCell") as! AttendanceItemCell
        
        cell.Date.text = _displayData[indexPath.row].OccurDate
        cell.Type.text = _displayData[indexPath.row].AbsenceType + " (\(_displayData[indexPath.row].Value))"
        cell.Periods.text = _displayData[indexPath.row].Period
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return _CurrentSemester?.Description
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
        if _displayData[indexPath.row].AbsenceType == "summaryItem"{
            return 30
        }
        
        return 62
    }
    
}

struct AttendanceItem{
    var OccurDate : String
    var SchoolYear : String
    var Semester : String
    var AbsenceType : String
    var Period : String
    var Value : Int
}

struct SemesterItem : Equatable,Comparable{
    var SchoolYear : String
    var Semester : String
    
    var Description: String {
        get {
            return "第\(SchoolYear)學年度\(Semester)學期"
        }
    }
    
    var CompareValue : Int{
        if let sy = SchoolYear.toInt() , let sm = Semester.toInt(){
            return sy * 10 + sm
        }
        else{
            return 0
        }
    }
}

func ==(lhs: SemesterItem, rhs: SemesterItem) -> Bool {
    return lhs.SchoolYear == rhs.SchoolYear && lhs.Semester == rhs.Semester
}

func <(lhs: SemesterItem, rhs: SemesterItem) -> Bool{
    return lhs.CompareValue < rhs.CompareValue
}

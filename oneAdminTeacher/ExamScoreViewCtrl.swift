//
//  ExamScoreViewCtrl.swift
//  oneAdminTeacher
//
//  Created by Cloud on 7/7/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class ExamScoreViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var _isJH = false
    var _isHS = false
    
    var _con = Connection()
    
    var _data = [ExamScoreItem]()
    var _displayData = [DisplayItem]()
    var _Semesters = [SemesterItem]()
    var _CurrentSemester : SemesterItem!
    var StudentData : Student!
    
    var progressTimer : ProgressTimer!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progress: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        progressTimer = ProgressTimer(progressBar: progress)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: "ChangeSemester")
        
        CommonConnect(StudentData.DSNS, _con, self)
        CheckDSNS()
        
        if self._isJH{
            _data = GetJHData()
        }
        else{
            _data = GetSHData()
        }
        
        _Semesters = GetSemesters(_data)
        
        tableView.reloadData()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ChangeSemester(){
        let actionSheet = UIAlertController(title: "請選擇學年度學期", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        actionSheet.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        for semester in _Semesters{
            actionSheet.addAction(UIAlertAction(title: semester.Description, style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                self.SetDataToTableView(semester)
            }))
        }
        
        self.presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func SetDataToTableView(semester:SemesterItem){
        
        self._CurrentSemester = semester
        var currentDatas = [ExamScoreItem]()
        
        for data in _data{
            if data.SchoolYear == semester.SchoolYear && data.Semester == semester.Semester{
                currentDatas.append(data)
            }
        }
        
        var displayData = [DisplayItem]()
        
        for d in currentDatas{
            
            displayData.append(DisplayItem(Title: d.Subject, Value: "", OtherInfo: "summaryItem", ColorAlarm: true))
            
            var exams = d.Exam
            exams.sort({$0.DisplayOrder < $1.DisplayOrder})
            
            var lastScore = Double.NaN
            
            for exam in exams{
                
                var result : String!
                
                if lastScore.isNaN || exam.Score.doubleValue == lastScore{
                    result = "event"
                }
                else if exam.Score.doubleValue > lastScore{
                    result = "up"
                }
                else{
                    result = "down"
                }
                
                lastScore = exam.Score.isEmpty ? Double.NaN : exam.Score.doubleValue
                
                displayData.append(DisplayItem(Title: exam.ExamName, Value: "\(exam.Score)", OtherInfo: result, ColorAlarm: true))
            }
        }
        
        _displayData = displayData
        
        tableView.reloadData()
    }
    
    func GetSHData() -> [ExamScoreItem]{
        
        var retVal = [ExamScoreItem]()
        
        var err : DSFault!
        var rsp = _con.sendRequest("examScore.GetExamScoreSH", bodyContent: "<Request><Condition><StudentID>\(StudentData.ID)</StudentID></Condition></Request>", &err)
        
        println(rsp)
        
        var nserr : NSError?
        
        let xml = AEXMLDocument(xmlData: rsp.dataValue, error: &nserr)
        
        if let semes = xml?.root["ExamScoreList"]["Seme"].all{
            for seme in semes{
                let schoolYear = seme.attributes["SchoolYear"] as! String
                let semester = seme.attributes["Semester"] as! String
                
                if let courses = seme["Course"].all{
                    for course in courses{
                        
                        let subject = course.attributes["Subject"] as! String
                        let credit = course.attributes["Credit"] as! String
                        
                        var examItem = ExamScoreItem(SchoolYear: schoolYear, Semester: semester, Subject: subject, Exam: [ExamDetailItem](), Domain: "", Credit: credit)
                        
                        if let exams = course["Exam"].all{
                            for exam in exams{
                                let examDisplayOrder = (exam.attributes["ExamDisplayOrder"] as! String).intValue
                                let examName = exam.attributes["ExamName"] as! String
                                let score = exam["ScoreDetail"].attributes["Score"] as! String
                                
                                let examDetailItem = ExamDetailItem(DisplayOrder: examDisplayOrder, ExamName: examName, Score: score, State: ExamDetailState.Event)
                                
                                examItem.Exam.append(examDetailItem)
                            }
                        }
                        
                        retVal.append(examItem)
                    }
                    
                }
                
            }
        }
        
        return retVal
    }
    
    func GetJHData() -> [ExamScoreItem]{
        
        var retVal = [ExamScoreItem]()
        
        var err : DSFault!
        var rsp = _con.sendRequest("examScore.GetExamScoreJH", bodyContent: "<Request><Condition><StudentID>\(StudentData.ID)</StudentID></Condition></Request>", &err)
        
        println(rsp)
        
        return retVal
    }
    
    //new solution
    func CheckDSNS() {
        
        self._isJH = false
        self._isHS = false
        
        //encode成功呼叫查詢
        if let encodingName = StudentData.DSNS.UrlEncoding{
            
            var data = HttpClient.Get("http://dsns.1campus.net/campusman.ischool.com.tw/config.public/GetSchoolList?content=%3CRequest%3E%3CMatch%3E\(encodingName)%3C/Match%3E%3CPagination%3E%3CPageSize%3E10%3C/PageSize%3E%3CStartPage%3E1%3C/StartPage%3E%3C/Pagination%3E%3C/Request%3E")
            
            if let rsp = data{
                
                var nserr : NSError?
                
                let xml = AEXMLDocument(xmlData: rsp, error: &nserr)
                
                if let coreSystem = xml?.root["Response"]["School"]["CoreSystem"].stringValue{
                    
                    if coreSystem == "國中新竹" || coreSystem == "實驗雙語部"{
                        self._isJH = true
                        self._isHS = true
                    }
                    else if coreSystem == "國中高雄"{
                        self._isJH = true
                    }
                    
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _displayData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let data = _displayData[indexPath.row]
        
        var cell = tableView.dequeueReusableCellWithIdentifier("summaryItem") as? UITableViewCell
        
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "summaryItem")
            cell?.textLabel?.textColor = UIColor(red: 19/255, green: 144/255, blue: 255/255, alpha: 1)
        }
        
        cell!.textLabel?.text = data.Title
        cell!.detailTextLabel?.text = data.Value
        
        let lab = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        lab.textAlignment = NSTextAlignment.Center
        lab.text = ""
        
        if data.OtherInfo == "up"{
            lab.text = "U"
        }
        else if data.OtherInfo == "down"{
            lab.text = "D"
        }
        
        cell?.accessoryView = lab
        
        return cell!
    }
    
}

struct ExamScoreItem : SemesterProtocol{
    var SchoolYear:String
    var Semester:String
    var Subject:String
    var Exam:[ExamDetailItem]
    var Domain:String
    //var Score:String
    //var AssignmentScore:String
    var Credit:String
    //var State:String
    //var Avg:String
}

struct ExamDetailItem {
    var DisplayOrder : Int
    var ExamName : String
    var Score : String
    var State : ExamDetailState
}

enum ExamDetailState : Int{
    case High,Low,Event
}
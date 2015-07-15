//
//  Global.swift
//  oneAdminTeacher
//
//  Created by Cloud on 6/25/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import Foundation
import UIKit

public class Global{
    //目前跟南港app是同一組
    static var clientID = "8e306edeffab96c8bdc6c8635cd54b9e"
    static var clientSecret = "b6b23657bfc3fc7dbf1014712308b005cae629b62376fac5f5a01632df91574e"
    static var AccessToken : String!
    static var RefreshToken : String!
    static var DsnsList : [DsnsItem]!
    static var CurrentDsns : DsnsItem!
    static var Students = [Student]()
    static var CurrentStudent : Student!
    static var CountProgressTime = [ProgressTimer]()
    static var ClassList : [ClassItem]!
    
    static func DeleteStudent(student:Student){
        var newData = [Student]()
        
        for stu in Students{
            if stu != student{
                newData.append(stu)
            }
        }
        
        if CurrentStudent != nil && CurrentStudent == student{
            CurrentStudent = nil
        }
        
        Students = newData
    }
    
    static func SetAccessTokenAndRefreshToken(token:(accessToken:String,refreshToken:String)!){
        if token != nil{
            self.AccessToken = token.accessToken
            self.RefreshToken = token.refreshToken
        }
    }
}

class ProgressTimer : NSObject{
    var ProgressBar : UIProgressView!
    var Timer : NSTimer?
    private var limitTime : Int
    
    init(progressBar:UIProgressView){
        ProgressBar = progressBar
        ProgressBar.hidden = true
        limitTime = 0
    }

    func StartProgress(){
        Timer?.invalidate()
        Timer = NSTimer.scheduledTimerWithTimeInterval(0.01667, target: self, selector: "timerCallback", userInfo: nil, repeats: true)
        ProgressBar.hidden = false
        ProgressBar.progress = 0.0
    }
    
    func StopProgress(){
        ProgressBar.progress = 1.0
        ProgressBar.hidden = true
        Timer?.invalidate()
        Timer = nil
        limitTime = 0
    }
    
    func timerCallback() {
        
        limitTime++
        
        if limitTime > 200{
            StopProgress()
            return
        }
        
        //println("still running...\(limitTime)")
        
        if !ProgressBar.hidden{
            if ProgressBar.progress >= 0.95{
                ProgressBar.progress = 0.95
            }
            else{
                ProgressBar.progress += 0.05
            }
        }
    }
}

func CommonConnect(dsns:String,con:Connection,vc:UIViewController){
    
    var err: DSFault!
    
    //con.connect(Global.CurrentDsns.AccessPoint, "ischool.teacher.app", SecurityToken.createOAuthToken(Global.AccessToken), &err)
    con.connect(dsns, "ischool.teacher.app", SecurityToken.createOAuthToken(Global.AccessToken), &err)
    
    if err != nil{
        ShowErrorAlert(vc,err,nil)
    }
}

func ShowErrorAlert(vc:UIViewController,err:DSFault,callback:(() -> ())!){
    let alert = UIAlertController(title: "錯誤", message: err.message, preferredStyle: UIAlertControllerStyle.Alert)
    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
        if callback != nil{
            callback()
        }
    }))
    vc.presentViewController(alert, animated: true, completion: nil)
}

//整理出資料的學年度學期並回傳
func GetSemesters<T>(datas:[T]) -> [SemesterItem]{
    
    var retVal = [SemesterItem]()
    var newData = [SemesterProtocol]()
    
    for data in datas{
        if let sp = data as? SemesterProtocol{
            newData.append(sp)
        }
    }
    
    for data in newData{
        let semester = SemesterItem(SchoolYear: data.SchoolYear, Semester: data.Semester)
        if !contains(retVal, semester){
            retVal.append(semester)
        }
    }
    
    if retVal.count > 0{
        retVal.sort({$0 > $1})
    }
    
    return retVal
}

func ChangeContentView(vc:UIViewController){
    var app = UIApplication.sharedApplication().delegate as! AppDelegate
    
    app.centerContainer?.setCenterViewController(vc, withCloseAnimation: true, completion: nil)
    //app.centerContainer?.closeDrawerAnimated(true, completion: nil)
//    app.centerContainer?.closeDrawerAnimated(true, completion: { (finish) -> Void in
//        app.centerContainer?.centerViewController = vc
//        
//        app.centerContainer?.setCenterViewController(<#newCenterViewController: UIViewController!#>, withFullCloseAnimation: <#Bool#>, completion: <#((Bool) -> Void)!##(Bool) -> Void#>)
//    })
    //app.centerContainer?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
}






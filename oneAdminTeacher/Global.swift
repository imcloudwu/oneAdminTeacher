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
    static var clientID = "9403ec217a19a849d498a5c18909bf38"
    static var clientSecret = "40654f9b8d2ddbf54d8f3059c2d70cd80d4e7e0fa3094d5b19305f945a38f025"
    static var MyPhotoLocalPath = NSHomeDirectory().stringByAppendingString("/Documents/myPhoto2.dat")
    static var MyPhoto : UIImage!
    static var MyName : String!
    static var MyEmail : String!
    static var MyDeviceToken : String!
    static var AccessToken : String!
    static var RefreshToken : String!
    static var DsnsList : [DsnsItem]!
    static var CurrentDsns : DsnsItem!
    static var Students = [Student]()
    static var CurrentStudent : Student!
    static var CountProgressTime = [ProgressTimer]()
    static var ClassList : [ClassItem]!
    static var Alert : UIAlertController!
    
    static var LastLoginDateTime : NSDate!
    
    static func Reset(){
        MyPhoto = nil
        ClassList = nil
        
        let fm = NSFileManager()
        fm.removeItemAtPath(MyPhotoLocalPath, error: nil)
    }
    
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
        
        self.AccessToken = nil
        self.RefreshToken = nil
        
        if token != nil{
            self.AccessToken = token.accessToken
            self.RefreshToken = token.refreshToken
            
            Keychain.save("refreshToken", data: RefreshToken.dataValue)
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
        
        if limitTime > 1000{
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
        //ShowErrorAlert(vc,"錯誤來自:\(dsns)",err.message)
    }
}

func ShowErrorAlert(vc:UIViewController,title:String,msg:String){
    
    if Global.Alert == nil{
        Global.Alert = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        Global.Alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
    }
    
    Global.Alert.title = title
    Global.Alert.message = msg
    
//    let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
//    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
//        if callback != nil{
//            callback()
//        }
//    }))
    
    
    vc.presentViewController(Global.Alert, animated: true, completion: nil)
    
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

func EnableSideMenu(){
    var app = UIApplication.sharedApplication().delegate as! AppDelegate
    
    app.centerContainer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.PanningCenterView
    app.centerContainer?.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.PanningCenterView | MMCloseDrawerGestureMode.TapCenterView
}

func DisableSideMenu(){
    var app = UIApplication.sharedApplication().delegate as! AppDelegate
    
    app.centerContainer?.openDrawerGestureModeMask = MMOpenDrawerGestureMode.None
    app.centerContainer?.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.None
}

func GetAccessTokenAndRefreshToken(code:String){
    var error : NSError?
    var oautHelper = OAuthHelper(clientId: Global.clientID, clientSecret: Global.clientSecret)
    let token = oautHelper.getAccessTokenAndRefreshToken(code, error: &error)
    //println(token)
    Global.SetAccessTokenAndRefreshToken(token)
    
    //println("AccessToken = \(Global.AccessToken)")
    //println("RefreshToken = \(Global.RefreshToken)")
}

func RenewRefreshToken(refreshToken:String){
    var error : NSError?
    var oautHelper = OAuthHelper(clientId: Global.clientID, clientSecret: Global.clientSecret)
    let token = oautHelper.renewAccessToken(refreshToken, error: &error)
    Global.SetAccessTokenAndRefreshToken(token)
}






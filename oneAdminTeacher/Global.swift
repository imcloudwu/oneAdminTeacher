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
    weak var ProgressBar : UIProgressView!
    var Timer : NSTimer?
    
    init(progressBar:UIProgressView){
        ProgressBar = progressBar
    }
    
    func StartProgress(){
        Timer = NSTimer.scheduledTimerWithTimeInterval(0.01667, target: self, selector: "timerCallback", userInfo: nil, repeats: true)
        ProgressBar.hidden = false
        ProgressBar.progress = 0.0
    }
    
    func StopProgress(){
        ProgressBar.progress = 1.0
        ProgressBar.hidden = true
        Timer?.invalidate()
        Timer = nil
    }
    
    func timerCallback() {
        if !ProgressBar.hidden{
            if ProgressBar?.progress >= 0.95{
                ProgressBar?.progress = 0.95
            }
            else{
                ProgressBar?.progress += 0.05
            }
        }
    }
}



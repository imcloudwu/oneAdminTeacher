//
//  NotificationService.swift
//  oneAdminTeacher
//
//  Created by Cloud on 7/27/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

public class NotificationService{
    
    private static var registerUrl : String = "https://1campus.net/notification/device/api/post/token/%@"
    
    private static var unRegisterUrl : String = "https://1campus.net/notification/device/api/put/dismiss/token/%@"
    
    private static var getMessageUrl : String = "https://1campus.net/notification/api/get/all/p/%@/token/%@"
    
    private static var getMessageCountUrl : String = "https://1campus.net/notification/api/get/all/count/token/%@"
    
    private static var setReadUrl : String = "https://1campus.net/notification/api/put/read/token/%@"
    
    private static var newMessageDelegate : (() -> ())?
    
    static func SetNewMessageDelegate(callback:(()->())?){
        newMessageDelegate = callback
    }
    
    static func ExecuteNewMessageDelegate(){
        
        if newMessageDelegate != nil{
            newMessageDelegate!()
        }
    }
    
    //註冊裝置
    static func Register(deviceToken:String?,accessToken:String,callback:()->()){
        
        if let dt = deviceToken{
            let req = "{\"deviceType\": \"ios\",\"deviceToken\": \"\(dt)\"}"
            
            let url = NSString(format: registerUrl, accessToken)
        
            HttpClient.Post(url as String, json: req, successCallback: { (response) -> Void in
                //println("success")
                
                callback()
                
                }, errorCallback: { (error) -> Void in
                    //println("failed")
                    
                    callback()
                    
                }, prepareCallback: nil)
        }
        else{
            callback()
        }
    }
    
    //反註冊裝置
    static func UnRegister(deviceToken:String?,accessToken:String){
        
        if let dt = deviceToken{
            let req = "{\"deviceType\": \"ios\",\"deviceToken\": \"\(dt)\"}"
            
            let url = NSString(format: unRegisterUrl, accessToken)
            
            var error : NSError?
            
            HttpClient.Put(url as String, body: req, err: &error)
        }
    }
    
    //取得訊息數量
    static func GetMessageCount(accessToken:String) -> Int{
        
        let url = NSString(format: getMessageCountUrl, accessToken)
        
        var rsp = HttpClient.Get(url as String)
        //println(NSString(data: rsp!, encoding: NSUTF8StringEncoding))
        
        if let data = rsp{
            
            let json = JSON(data: data)
            
            let count = json["count"].intValue
            
            return count
        }
        
        return 0
    }
    
    //取得訊息
    static func GetMessage(page:String,accessToken:String) -> NSData{
        
        let url = NSString(format: getMessageUrl, page, accessToken)
        
        if let data = HttpClient.Get(url as String){
            return data
        }
        
        return NSData()
    }
    
    //設為已讀
    static func SetRead(msgId:String,accessToken:String){
        
        let url = NSString(format: setReadUrl, accessToken)
        
        var error : NSError?
        
        HttpClient.Put(url as String, body: "[\"\(msgId)\"]", err: &error)
    }
}

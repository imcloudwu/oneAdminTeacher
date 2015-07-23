//
//  MessageViewCtrl.swift
//  oneAdminTeacher
//
//  Created by Cloud on 7/22/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//
import UIKit

class MessageViewCtrl: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var messageData = [MessageItem]()
    
    var _dateFormate = NSDateFormatter()
    var _timeFormate = NSDateFormatter()
    
    var _today : String!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _dateFormate.dateFormat = "yyyy/MM/dd"
        _timeFormate.dateFormat = "HH:mm"
        
        _today = _dateFormate.stringFromDate(NSDate())
        
        tableView.delegate = self
        tableView.dataSource = self
        
        var data = HttpClient.Get("https://1campus.net/notification/api/get/new/count/token/" + Global.AccessToken)
        //println(NSString(data: data!, encoding: NSUTF8StringEncoding))
        
        let json = JSON(data: data!)
        
        let count = json["count"].intValue
        
        var mod = count % 10
        
        if mod > 0 {
            mod = 1
        }
        
        for i in 1...(count / 10) + mod{
            var rsp = HttpClient.Get("https://1campus.net/notification/api/get/new/p/\(i)/token/" + Global.AccessToken)
            println(NSString(data: rsp!, encoding: NSUTF8StringEncoding))
            
            var jsons = JSON(data: rsp!)
            
            var format:NSDateFormatter = NSDateFormatter()
            format.dateFormat = "yyyy-MM-dd HH:mm:ss"
            //format.timeZone = NSTimeZone(name: "Asia/Taipei")
            
            for (index,obj) in jsons {
                //let dateTime = (obj["time"].stringValue as NSString).substringToIndex(10).stringByReplacingOccurrencesOfString("-", withString: "/")
                let dateTime = obj["time"].stringValue as NSString
                let date = dateTime.substringToIndex(10)
                let time = (dateTime.substringFromIndex(11) as NSString).substringToIndex(8)
                let message = obj["message"].stringValue
                let redirect = obj["redirect"].stringValue
                let sender = obj["from"]["sender"].stringValue
                let dsnsname = obj["from"]["group"]["dsnsname"].stringValue
                let name = obj["from"]["group"]["name"].stringValue
                
                var parseDate = format.dateFromString(date + " " + time)
                
                var newDate = parseDate?.dateByAddingTimeInterval(Double(60*60*8))
                
                messageData.append(MessageItem(Date: newDate!, Title: sender, Content: message, Redirect: redirect, DsnsName: dsnsname, Name: name))
            }
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationItem.title = "我的訊息"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return messageData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let data = messageData[indexPath.row]
        
        var date = _dateFormate.stringFromDate(data.Date)
        
        var cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        cell.Title.text = data.Title
        cell.Date.text = _today == date ? _timeFormate.stringFromDate(data.Date) : date
        cell.Content.text = data.Content
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        let data = messageData[indexPath.row]
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("MessageDetailViewCtrl") as! MessageDetailViewCtrl
        nextView.MessageData = data
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
}

struct MessageItem{
    var Date : NSDate
    var Title : String
    var Content : String
    var Redirect : String
    var DsnsName : String
    var Name : String
}

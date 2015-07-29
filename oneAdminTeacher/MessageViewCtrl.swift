//
//  MessageViewCtrl.swift
//  oneAdminTeacher
//
//  Created by Cloud on 7/22/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//
import UIKit
import Parse

class MessageViewCtrl: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    var messageData = [MessageItem]()
    var LocalMsg = [MessageItem]()
    
    var _dateFormate = NSDateFormatter()
    var _timeFormate = NSDateFormatter()
    var _boldFont = UIFont.boldSystemFontOfSize(17.0)
    var _normalFont = UIFont.systemFontOfSize(17.0)
    
    @IBOutlet weak var progress: UIProgressView!
    
    var progressTimer : ProgressTimer!
    
    var _today : String!
    
    var isFirstLoad = true
    var UnReadCount = 0
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl : UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ResetBadge()
        
        let sideMenuBtn = UIBarButtonItem(image: UIImage(named: "Menu Filled-25.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "ToggleSideMenu")
        self.navigationItem.leftBarButtonItem = sideMenuBtn
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: "ReloadData", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        self.navigationController?.interactivePopGestureRecognizer.enabled = false
        
        progressTimer = ProgressTimer(progressBar: progress)
        
        _dateFormate.dateFormat = "yyyy/MM/dd"
        _timeFormate.dateFormat = "HH:mm"
        
        _today = _dateFormate.stringFromDate(NSDate())
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        SetViewTitle()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        NotificationService.SetNewMessageDelegate { () -> () in
            self.ReloadData()
        }
        
        if !isFirstLoad{
            return
        }
        
        ReloadData()
    }
    
    override func viewDidDisappear(animated: Bool) {
        NotificationService.SetNewMessageDelegate(nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ResetBadge(){
        PFInstallation.currentInstallation().badge = 0
        PFInstallation.currentInstallation().saveInBackground()
    }
    
    func SetViewTitle(){
        self.navigationItem.title = UnReadCount > 0 ? "我的訊息 (\(UnReadCount) 封未讀)" : "我的訊息"
    }
    
    func ReloadData(){
        
        isFirstLoad = false
        
        self.refreshControl.endRefreshing()
        
        progressTimer.StartProgress()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            for msg in self.GetNewMessageData(){
                MessageCoreData.SaveCatchData(msg)
            }
            
            self.messageData = MessageCoreData.LoadCatchData()
            
            var unread = 0
            
            for msg in self.messageData{
                unread += msg.IsNew ? 1 : 0
            }
            
            self.UnReadCount = unread
            
            dispatch_async(dispatch_get_main_queue(), {
                self.tableView.reloadData()
                self.SetViewTitle()
                self.progressTimer.StopProgress()
            })
        })
    }
    
    func GetNewMessageData() -> [MessageItem]{
        
        var retVal = [MessageItem]()
        
        //計算要更新的數量
        let count = NotificationService.GetMessageCount(Global.AccessToken) - MessageCoreData.GetCount()
        
        if count == 0{
            return retVal
        }
        
        var mod = count % 10
        
        if mod > 0 {
            mod = 1
        }
        
        for i in 1...(count / 10) + mod{
            
            //取得訊息
            var jsons = JSON(data: NotificationService.GetMessage("\(i)", accessToken: Global.AccessToken))
            
            var format:NSDateFormatter = NSDateFormatter()
            format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
            //format.timeZone = NSTimeZone(name: "Asia/Taipei")
            
            for (index,obj) in jsons {
                
                let dateTime = obj["time"].stringValue
                
                let id = obj["_id"].stringValue
                let isNew = obj["new"].stringValue == "true" ? true : false
                let message = obj["message"].stringValue
                let redirect = obj["redirect"].stringValue
                let sender = obj["from"]["sender"].stringValue
                let dsnsname = obj["from"]["group"]["dsnsname"].stringValue
                let name = obj["from"]["group"]["name"].stringValue
                
                let newDate = format.dateFromString(dateTime)
                
                retVal.append(MessageItem(id: id, date: newDate!, isNew: isNew, title: sender, content: message, redirect: redirect, dsnsName: dsnsname, name: name))
            }
        }
        
        return retVal
    }
    
    func ToggleSideMenu(){
        var app = UIApplication.sharedApplication().delegate as! AppDelegate
        
        app.centerContainer?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return messageData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let data = messageData[indexPath.row]
        
        var date = _dateFormate.stringFromDate(data.Date)
        
        var cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        cell.Title.font = data.IsNew ? _boldFont : _normalFont
        cell.Title.text = data.Title
        cell.Date.text = _today == date ? _timeFormate.stringFromDate(data.Date) : date
        cell.Date.textColor = data.IsNew ? UIColor(red: 19 / 255, green: 144 / 255, blue: 255 / 255, alpha: 1) : UIColor.lightGrayColor()
        cell.Content.text = data.Content
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        let data = messageData[indexPath.row]
        var cell = tableView.cellForRowAtIndexPath(indexPath) as! MessageCell
        
        if data.IsNew{
            data.IsNew = false
            UnReadCount--
            
            cell.Title.font = _normalFont
            cell.Date.textColor = data.IsNew ? UIColor(red: 19 / 255, green: 144 / 255, blue: 255 / 255, alpha: 1) : UIColor.lightGrayColor()
        }
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("MessageDetailViewCtrl") as! MessageDetailViewCtrl
        nextView.MessageData = data
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
}

class MessageItem : Equatable{
    var Id : String
    var Date : NSDate
    var IsNew : Bool
    var Title : String
    var Content : String
    var Redirect : String
    var DsnsName : String
    var Name : String
    
    init(id: String, date: NSDate, isNew: Bool, title: String, content: String, redirect: String, dsnsName: String, name: String){
        Id = id
        Date = date
        IsNew = isNew
        Title = title
        Content = content
        Redirect = redirect
        DsnsName = dsnsName
        Name = name
    }
}

func ==(lhs: MessageItem, rhs: MessageItem) -> Bool {
    return lhs.Id == rhs.Id
}

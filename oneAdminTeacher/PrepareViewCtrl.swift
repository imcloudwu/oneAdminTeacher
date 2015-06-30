//  Created by Cloud on 6/12/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class PrepareViewCtrl: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    
    var code : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.statusLabel.text = "取得AccessToken..."
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            self.GetAccessTokenAndRefreshToken(self.code)
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.statusLabel.text = "取得DSNS清單..."
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                    
                    self.GetDsnsList()
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("schoolOptionsView") as! UIViewController
                        self.presentViewController(nextView, animated: true, completion: nil)
                    })
                })
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func ChancelLogin(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
    
    func GetDsnsList(){
        
        var dsnsList = [DsnsItem]()
        
        var nserr : NSError?
        var dserr : DSFault!
        
        let con = Connection()
        
        if con.connect("https://auth.ischool.com.tw:8443/dsa/greening", "user", SecurityToken.createOAuthToken(Global.AccessToken), &dserr){
            var rsp = con.sendRequest("GetApplicationListRef", bodyContent: "<Request><Type>dynpkg</Type></Request>", &dserr)
            
            let xml = AEXMLDocument(xmlData: rsp.dataValue, error: &nserr)
            //println(xml?.xmlString)
            
            if let apps = xml?.root["Response"]["User"]["App"].all {
                for app in apps{
                    let title = app.attributes["Title"] as! String
                    let accessPoint = app.attributes["AccessPoint"] as! String
                    let dsns = DsnsItem(name: title, accessPoint: accessPoint)
                    if !contains(dsnsList,dsns){
                        dsnsList.append(dsns)
                    }
                }
            }
            
            if let apps = xml?.root["Response"]["Domain"]["App"].all {
                for app in apps{
                    let title = app.attributes["Title"] as! String
                    let accessPoint = app.attributes["AccessPoint"] as! String
                    let dsns = DsnsItem(name: title, accessPoint: accessPoint)
                    if !contains(dsnsList,dsns){
                        dsnsList.append(dsns)
                    }
                }
            }
        }
        
        Global.DsnsList = dsnsList
        
    }
}

class DsnsItem : Equatable{
    
    var Name : String
    var AccessPoint : String
    
    init(name:String,accessPoint:String){
        self.Name = name
        self.AccessPoint = accessPoint
    }
}

func ==(lhs: DsnsItem, rhs: DsnsItem) -> Bool {
    return lhs.AccessPoint == rhs.AccessPoint
}


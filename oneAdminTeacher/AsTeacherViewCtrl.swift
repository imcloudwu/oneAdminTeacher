//
//  AsTeacherViewCtrl.swift
//  oneAdminTeacher
//
//  Created by Cloud on 2016/1/28.
//  Copyright © 2016年 ischool. All rights reserved.
//

import UIKit

class AsTeacherViewCtrl: UIViewController,UITextFieldDelegate,UIWebViewDelegate {
    
    var _selectDsns : DsnsItem!
    
    var webView : UIWebView!
    
    @IBOutlet weak var selectSchoolBtn: UIButton!
    
    @IBOutlet weak var codeTextField: UITextField!
    
    @IBAction func selectSchoolBtnClick(sender: AnyObject) {
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("SelectSchoolViewCtrl") as! SelectSchoolViewCtrl
        
        nextView._SelectedSchool = _selectDsns
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        codeTextField.delegate = self
        
        webView = UIWebView()
        webView.hidden = true
        webView.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        self.webView.frame = self.view.bounds
        self.view.addSubview(self.webView)
        
        if _selectDsns == nil{
            _selectDsns = DsnsItem(name: "選擇學校", accessPoint: "")
        }
        
        selectSchoolBtn.setTitle(_selectDsns.Name, forState: UIControlState.Normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // called when 'return' key pressed. return NO to ignore.
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        self.view.endEditing(true)
        
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func Submit(sender: AnyObject) {
        
        if self._selectDsns.AccessPoint.isEmpty{
            ShowErrorAlert(self, title: "請選擇學校", msg: "")
            return
        }
        
        if let code = self.codeTextField.text where code.isEmpty{
            ShowErrorAlert(self, title: "請輸入教師代碼", msg: "")
            return
        }
        
        AddApplicationRef(self._selectDsns.AccessPoint)
    }
    
    func AddApplicationRef(server:String){
        
        if !Global.DsnsList.contains(self._selectDsns){
            
            var err : DSFault!
            let con = Connection()
            con.connect("https://auth.ischool.com.tw:8443/dsa/greening", "user", SecurityToken.createOAuthToken(Global.AccessToken), &err)
            
            if err != nil{
                ShowErrorAlert(self, title: "過程發生錯誤", msg: err.message)
                return
            }
            
            _ = con.sendRequest("AddApplicationRef", bodyContent: "<Request><Applications><Application><AccessPoint>\(server)</AccessPoint><Type>dynpkg</Type></Application></Applications></Request>", &err)
            
            if err != nil{
                ShowErrorAlert(self, title: "過程發生錯誤", msg: err.message)
                return
            }
            
            Global.DsnsList.append(self._selectDsns)
            
            ShowWebView()
        }
        else{
            JoinAsTeacher()
        }
    }
    
    func JoinAsTeacher(){
        
        var err : DSFault!
        let con = Connection()
        con.connect(self._selectDsns.AccessPoint, "auth.guest", SecurityToken.createOAuthToken(Global.AccessToken), &err)
        
        if err != nil{
            ShowErrorAlert(self, title: "過程發生錯誤", msg: err.message)
            return
        }
        
        let rsp = con.SendRequest("Join.AsTeacher", bodyContent: "<Request><TeacherCode>\(self.codeTextField.text!)</TeacherCode></Request>", &err)
        
        if err != nil{
            ShowErrorAlert(self, title: "過程發生錯誤", msg: err.message)
            return
        }
        
        let xml = try? AEXMLDocument(xmlData: rsp.dataValue)
        
        if let id = xml?.root["Response"]["RefID"].stringValue where !id.isEmpty{
            
            let alert = UIAlertController(title: "加入成功", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
                
                self.navigationController?.popViewControllerAnimated(true)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else{
            ShowErrorAlert(self, title: "加入失敗", msg: "發生不明的錯誤,請回報給開發人員")
        }
        
    }
    
    func ShowWebView(){
        
        let target = "https://auth.ischool.com.tw/oauth/authorize.php?client_id=\(Global.clientID)&response_type=token&redirect_uri=http://_blank&scope=User.Mail,User.BasicInfo,1Campus.Notification.Read,1Campus.Notification.Send,*:auth.guest,*:sakura,*:\(Global.ContractName)&access_token=\(Global.AccessToken)"
        
        let urlobj = NSURL(string: target)
        let request = NSURLRequest(URL: urlobj!)
        
        self.webView.loadRequest(request)
        self.webView.hidden = false
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?){
        
        //網路異常
        if error!.code == -1009 || error!.code == -1003{
            
            if UpdateTokenFromError(error!){
                JoinAsTeacher()
            }
            else{
                ShowErrorAlert(self, title: "連線過程發生錯誤", msg: "若此情況重複發生,建議重登後再嘗試")
            }
        }
    }
    
    func UpdateTokenFromError(error: NSError) -> Bool{
        
        var accessToken : String!
        var refreshToken : String!
        
        if let url = error.userInfo["NSErrorFailingURLStringKey"] as? String{
            
            let stringArray = url.componentsSeparatedByString("&")
            
            if stringArray.count != 5{
                return false
            }
            
            if let range1 = stringArray[0].rangeOfString("http://_blank/#access_token="){
                accessToken = stringArray[0]
                accessToken.removeRange(range1)
            }
            
            if let range2 = stringArray[4].rangeOfString("refresh_token="){
                refreshToken = stringArray[4]
                refreshToken.removeRange(range2)
            }
        }
        
        if accessToken != nil && refreshToken != nil{
            Global.SetAccessTokenAndRefreshToken((accessToken: accessToken, refreshToken: refreshToken))
            return true
        }
        
        return false
    }
    
}


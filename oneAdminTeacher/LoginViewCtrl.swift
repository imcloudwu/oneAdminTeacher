import UIKit

class LoginViewCtrl: UIViewController,UIWebViewDelegate {
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet weak var ProgressBar: UIProgressView!
    
    var progressTimer : ProgressTimer!
    
    var Timer : NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        progressTimer = ProgressTimer(progressBar: ProgressBar)
        
        let reloadBtn =  UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "showLoginView")
        self.navigationItem.rightBarButtonItem = reloadBtn
        
        webView.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        showLoginView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showLoginView(){
        let target = "https://auth.ischool.com.tw/oauth/authorize.php?client_id=\(Global.clientID)&response_type=code&state=redirect_uri%3A%2F&redirect_uri=http://blank&lang=zh-tw"
        
        //載入登入頁面
        var urlobj = NSURL(string: target)
        var request = NSURLRequest(URL: urlobj!)
        webView.loadRequest(request)
    }
    
    func webViewDidStartLoad(webView: UIWebView){
        progressTimer.StartProgress()
    }
    
    func webViewDidFinishLoad(webView: UIWebView){
        progressTimer.StopProgress()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError){
        
        progressTimer.StopProgress()
        
        //網路異常
        if error.code == -1009{
            
            if let code = GetCodeFromError(error){
                GotoNextView(code)
            }
            else{
                let alert = UIAlertController(title: "網路無法連線", message: "請點選右上方的重新整理", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
        //取得code
        if error.domain == "NSURLErrorDomain" && error.code == -1003{
            
            if let code = GetCodeFromError(error){
                GotoNextView(code)
            }
        }
    }
    
    func GetCodeFromError(error: NSError) -> String?{
        if let url = error.userInfo?["NSErrorFailingURLStringKey"] as? String{
            if let range = url.rangeOfString("http://blank/?state=redirect_uri%3A%2F&code="){
                var code = url
                code.removeRange(range)
                
                //println(code)
                
                return code
            }
        }
        
        return nil
    }
    
    func GotoNextView(code:String){
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("prepareViewCtrl") as! PrepareViewCtrl
        nextView.code = code
        ChangeContentView(nextView)
        //self.presentViewController(nextView, animated: true, completion: nil)
    }
}








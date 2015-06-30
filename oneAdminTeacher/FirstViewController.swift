//  Created by Cloud on 6/12/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
        var err: DSFault!
        var con = Connection()
        
        if con.connect("dev.sh_d", "auth.guest", SecurityToken.createOAuthToken("xxxxx"), &err) {
            var rsp = con.sendRequest("", bodyContent: "", &err)
        }
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


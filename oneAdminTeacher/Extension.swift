//
//  Extension.swift
//  oneAdminTeacher
//
//  Created by Cloud on 7/7/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import Foundation

//extension Optional{
//    func ParseInt() -> Int{
//        if let str = self as? String{
//            return str.toInt() ?? 0
//        }
//
//        return 0
//    }
//}

//if failed will return 0
extension String {
    
    var intValue: Int {
        return self.toInt() ?? 0
    }
    
    var doubleValue: Double {
        return (self as NSString).doubleValue
    }
    
    public var UrlEncoding: String?{
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    }
}

//四捨五入到小數點第二位
extension Double {
    func toString() -> String {
        return String(format: "%.2f", self)
    }
}

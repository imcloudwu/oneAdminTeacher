//
//  CommonStruct.swift
//  oneAdminTeacher
//
//  Created by Cloud on 7/7/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import Foundation

struct DisplayItem{
    var Title : String
    var Value : String
    var OtherInfo : String
    var ColorAlarm : Bool
}

protocol SemesterProtocol
{
    var SchoolYear : String { get set }
    var Semester : String { get set }
}
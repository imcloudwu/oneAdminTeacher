//
//  CustomCell.swift
//  oneAdminTeacher
//
//  Created by Cloud on 6/12/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class StudentCell : UITableViewCell{
    
    @IBOutlet weak var Photo: UIImageView!
    @IBOutlet weak var Label1: UILabel!
    @IBOutlet weak var Label2: UILabel!
    @IBOutlet weak var Label3: UILabel!
    @IBOutlet weak var Label4: UILabel!
    
    override func awakeFromNib() {
        //
    }
}

class AbsentCell : UITableViewCell{
    
    @IBOutlet weak var Type: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Period: UILabel!
    
    override func awakeFromNib() {
        //
    }
}

class DisciplineCell : UITableViewCell{
    
    @IBOutlet weak var State: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var Reason: UILabel!
    
    override func awakeFromNib() {
        //
    }
}

class SemesterCell : UITableViewCell{
    
    @IBOutlet weak var Title: UILabel!
    
    override func awakeFromNib() {
        //
    }
}

class SemesterScoreCell : UITableViewCell{
    
    @IBOutlet weak var Subject: UILabel!
    @IBOutlet weak var Info: UILabel!
    @IBOutlet weak var Type: UILabel!
    
    override func awakeFromNib() {
        //
    }
}

class ExamScoreCell : UITableViewCell{
    
    @IBOutlet weak var Subject: UILabel!
    @IBOutlet weak var Credit: UILabel!
    @IBOutlet weak var ScoreA: UILabel!
    @IBOutlet weak var ScoreB: UILabel!
    @IBOutlet weak var ScoreC: UILabel!
    @IBOutlet weak var SubTitleA: UILabel!
    @IBOutlet weak var SubTitleB: UILabel!
    
    override func awakeFromNib() {
        //
    }
}

class ExamScoreTitleCell : UITableViewCell{
    
    @IBOutlet weak var Domain: UILabel!
    @IBOutlet weak var Score: UILabel!
    
    override func awakeFromNib() {
    }
}

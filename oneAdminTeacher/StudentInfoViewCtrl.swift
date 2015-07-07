//
//  StudentInfoViewCtrl.swift
//  oneAdminTeacher
//
//  Created by Cloud on 6/29/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class StudentInfoViewCtrl: UIViewController {
    
    @IBOutlet weak var Photo: UIImageView!
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var ClassName: UILabel!
    @IBOutlet weak var StudentNumber: UILabel!
    @IBOutlet weak var Gender: UILabel!
    @IBOutlet weak var CustodianName: UILabel!
    @IBOutlet weak var MailingAddress: UILabel!
    @IBOutlet weak var PermanentAddress: UILabel!
    @IBOutlet weak var FatherName: UILabel!
    @IBOutlet weak var FatherPhone: UILabel!
    @IBOutlet weak var MotherName: UILabel!
    @IBOutlet weak var MotherPhone: UILabel!
    
    var StudentData:Student!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "加入清單", style: UIBarButtonItemStyle.Plain, target: self, action: "AddToList")
        
        Photo.image = StudentData.Photo
        Name.text = StudentData.Name
        StudentNumber.text = StudentData.StudentNumber
        Gender.text = StudentData.Gender
        CustodianName.text = StudentData.CustodianName
        MailingAddress.text = GetAddress(StudentData.MailingAddress)
        PermanentAddress.text = GetAddress(StudentData.PermanentAddress)
        FatherName.text = StudentData.FatherName
        FatherPhone.text = StudentData.PermanentPhone
        MotherName.text = StudentData.MotherName
        MotherPhone.text = StudentData.ContactPhone
        
        var className = StudentData.ClassName + (StudentData.SeatNo == "" ? "" : "(\(StudentData.SeatNo))")
        
        ClassName.text = className
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        LockBtnEnableCheck()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func AddToList(){
        Global.Students.append(StudentData)
        LockBtnEnableCheck()
        
        //存入catch
        CoreData.SaveCatchData(StudentData)
    }
    
    func GetAddress(xmlString:String) -> String{
        var nserr : NSError?
        let xml = AEXMLDocument(xmlData: xmlString.dataValue, error: &nserr)
        
        var retVal = ""
        
        if let addresses = xml?.root["AddressList"]["Address"].all{
            for address in addresses{
                
                let zipCode = address["ZipCode"].stringValue == "" ? "" : "[" + address["ZipCode"].stringValue + "]"
                let county = address["County"].stringValue
                let town = address["Town"].stringValue
                let detailAddress = address["DetailAddress"].stringValue
                
                retVal = zipCode + county + town + detailAddress
                
                if retVal != ""{
                    return retVal
                }
            }
        }
        
        return "查無地址資料"
    }
    
    @IBAction func CallToFather(sender: AnyObject) {
        DialNumber(StudentData.PermanentPhone)
    }
    
    @IBAction func CallToMother(sender: AnyObject) {
        DialNumber(StudentData.ContactPhone)
    }
    
    func DialNumber(phoneNumber:String){
        let phone = "telprompt://" + phoneNumber
        let url:NSURL = NSURL(string:phone)!
        UIApplication.sharedApplication().openURL(url)
    }
    
    func LockBtnEnableCheck(){
        if contains(Global.Students, StudentData){
            self.navigationItem.rightBarButtonItem?.enabled = false
        }
        else{
            self.navigationItem.rightBarButtonItem?.enabled = true
        }
    }
}

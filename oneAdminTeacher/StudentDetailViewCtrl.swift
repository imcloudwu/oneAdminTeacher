//
//  StudentDetailViewCtrl.swift
//  oneAdminTeacher
//
//  Created by Cloud on 7/13/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class StudentDetailViewCtrl: UIViewController {
    
    @IBOutlet weak var SubTitleView: UIView!
    @IBOutlet weak var Height: NSLayoutConstraint!
    @IBOutlet weak var EmbedView: UIView!
    @IBOutlet weak var Segment: UISegmentedControl!
    
    @IBOutlet weak var PhotoImage: UIImageView!
    
    var ExpandBtn : UIBarButtonItem!
    
    var StudentData : Student!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var background = UIImageView(image: UIImage(named: "background2.png"))
        background.frame = SubTitleView.bounds
        //nback.contentMode = UIViewContentMode.ScaleAspectFill
        SubTitleView.insertSubview(background, atIndex: 0)
        
        //移除底端邊界
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        ExpandBtn = UIBarButtonItem(image: UIImage(named: "Expand Arrow-24.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "ChangeHeight")
        self.navigationItem.rightBarButtonItem = ExpandBtn
        
        PhotoImage.image = StudentData.Photo
        PhotoImage.layer.cornerRadius = PhotoImage.frame.size.width / 2
        PhotoImage.layer.masksToBounds = true
        
        PhotoImage.layer.borderWidth = 3.0
        PhotoImage.layer.borderColor = UIColor.whiteColor().CGColor
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        SegmentValueChange(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func SegmentValueChange(sender: AnyObject) {
        
        if Segment.selectedSegmentIndex == 0{
            var contentView = self.storyboard?.instantiateViewControllerWithIdentifier("studentInfoViewCtrl") as! StudentInfoViewCtrl
            ChangeContainerViewContent(contentView)
        }
        else if Segment.selectedSegmentIndex == 1{
            let contentView = self.storyboard?.instantiateViewControllerWithIdentifier("attendanceViewCtrl") as! AttendanceViewCtrl
            ChangeContainerViewContent(contentView)
        }
        else if Segment.selectedSegmentIndex == 2{
            let contentView = self.storyboard?.instantiateViewControllerWithIdentifier("disciplineViewCtrl") as! DisciplineViewCtrl
            ChangeContainerViewContent(contentView)
        }
        else if Segment.selectedSegmentIndex == 3{
            let contentView = self.storyboard?.instantiateViewControllerWithIdentifier("examScoreViewCtrl") as! ExamScoreViewCtrl
            ChangeContainerViewContent(contentView)
        }
        else if Segment.selectedSegmentIndex == 4{
            let contentView = self.storyboard?.instantiateViewControllerWithIdentifier("semesterScoreViewCtrl") as! SemesterScoreViewCtrl
            ChangeContainerViewContent(contentView)
        }
    }
    
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
//            println("landscape")
//        } else {
//            println("portraight")
//        }
//    }
    
    func ChangeHeight(){
        SubTitleView.hidden = !SubTitleView.hidden
        Height.constant = SubTitleView.hidden ? 0 : 133
    }
    
    func ChangeContainerViewContent(vc : UIViewController){
        
        DeteleRightBarButtonItems()
        
        childViewControllers.first?.removeFromParentViewController()
        
        //var newController = self.storyboard?.instantiateViewControllerWithIdentifier("test1") as! UIViewController
        
        SetContainViewData(vc)
        addChildViewController(vc)
        
        //newController.didMoveToParentViewController(self)
        
        for sub in EmbedView.subviews as! [UIView]{
            sub.removeFromSuperview()
        }
        
        vc.view.frame = EmbedView.bounds
        
        EmbedView.addSubview(vc.view)
        
        //            var newController = self.storyboard?.instantiateViewControllerWithIdentifier("test2") as! UIViewController
        //            let oldController = childViewControllers.last as? UIViewController
        //
        //            oldController?.willMoveToParentViewController(nil)
        //            addChildViewController(newController)
        //
        //            if let frame = oldController?.view.frame{
        //                newController.view.frame = frame
        //            }
        //
        //            oldController?.removeFromParentViewController()
        //            newController.didMoveToParentViewController(self)
        //            
        //            EmbedView.addSubview(newController.view)
    }
    
    func DeteleRightBarButtonItems(){
        if self.navigationItem.rightBarButtonItems?.count != 1{
            self.navigationItem.rightBarButtonItems?.removeLast()
            DeteleRightBarButtonItems()
        }
    }
    
    func SetContainViewData(vc : UIViewController){
        var cvp = vc as! ContainerViewProtocol
        cvp.StudentData = StudentData
        cvp.ParentNavigationItem = self.navigationItem
    }
}

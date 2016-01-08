//
//  StudentTagViewCtrl.swift
//  EPF
//
//  Created by Cloud on 10/20/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class StudentTagViewCtrl: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var selectAllBtn: UIButton!
    
    var _TagSelector : TagSelector!
    
    var _TmpTagSelector = TagSelector()
    
    var CellId = "tagStudent"
    
    @IBAction func SelectAll(sender: AnyObject) {
        
        if selectAllBtn.titleLabel?.text == "全部選擇"{
            selectAllBtn.setTitle("全部刪除", forState: UIControlState.Normal)
            
            _TmpTagSelector.Selected = _TagSelector.List
        }
        else{
            selectAllBtn.setTitle("全部選擇", forState: UIControlState.Normal)
            _TmpTagSelector.Selected.removeAll(keepCapacity: false)
        }
        
        self.tableView.reloadData()
        
        SetTitle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _TmpTagSelector.List = _TagSelector.List
        _TmpTagSelector.Selected = _TagSelector.Selected
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "確認", style: UIBarButtonItemStyle.Done, target: self, action: "Save")
        
        SetTitle()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func SetTitle(){
        self.navigationItem.title = "選擇了 \(_TmpTagSelector.Selected.count) 位"
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _TmpTagSelector.List.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let data = _TmpTagSelector.List[indexPath.row]
        
        var cell = tableView.dequeueReusableCellWithIdentifier(CellId)
        
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: CellId)
            cell?.accessoryType = UITableViewCellAccessoryType.None
        }
        
        cell?.textLabel?.text = data.StudentName
        //cell?.detailTextLabel?.text = data.Account
        
        if _TmpTagSelector.Selected.contains(data){
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else{
            cell?.accessoryType = UITableViewCellAccessoryType.None
        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        let data = _TmpTagSelector.List[indexPath.row]
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if _TmpTagSelector.Selected.contains(data){
            let index = _TmpTagSelector.IndexOf(data)
            _TmpTagSelector.Selected.removeAtIndex(index)
            cell?.accessoryType = UITableViewCellAccessoryType.None
        }
        else{
            _TmpTagSelector.Selected.append(data)
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        
        SetTitle()
    }
    
    func Save(){
        _TagSelector.Selected = _TmpTagSelector.Selected
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //Mark : SearchBar
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchText == "" {
            _TmpTagSelector.List = _TagSelector.List
        }
        else{
            
            let founds = _TagSelector.List.filter({ t in
                
                if let x = t.StudentName.lowercaseString.rangeOfString(searchText.lowercaseString){
                    return true
                }
                
                return false
            })
            
            _TmpTagSelector.List = founds
        }
        
        self.tableView.reloadData()
    }
    
}



//
//  AlbumsViewCtrl.swift
//  oneAdminTeacher
//
//  Created by Cloud on 12/31/15.
//  Copyright © 2015 ischool. All rights reserved.
//

import UIKit

class AlbumsViewCtrl: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    var progressTimer : ProgressTimer!
    
    var myAlbums = [AlbumItem]()
    
    var finishedDsns = [String:Bool]()
    
    var refreshControl : UIRefreshControl!
    
    var needReload = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: "Reload", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        progressTimer = ProgressTimer(progressBar: progressBar)
        
        self.navigationItem.title = "校園相簿"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "AddAlbum")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if myAlbums.count == 0{
           needReload = true
        }
        
        if needReload{
            needReload = false
            self.Reload()
        }
    }
    
    func AllDone() -> Bool{
        
        for dsns in finishedDsns{
            if !dsns.1{
                return false
            }
        }
        
        return true
    }
    
    func Reload(){
        
        self.refreshControl.endRefreshing()
        
        progressTimer.StartProgress()
        
        //check list init
        finishedDsns.removeAll(keepCapacity: false)
        for dsns in Global.DsnsList{
            finishedDsns[dsns.Name] = false
        }
        
        var albums = [AlbumItem]()
        
        for dsns in Global.DsnsList{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                
                let tmps = self.GetAlbums(dsns)
                
                dispatch_async(dispatch_get_main_queue(), {
                    
                    self.finishedDsns[dsns.Name] = true
                    
                    albums += tmps
                    
                    self.myAlbums = albums
                    
                    if self.AllDone(){
                        
                        self.progressTimer.StopProgress()
                        
                        self.tableView.reloadData()
                    }
                })
            })
        }
        
    }
    
    func GetAlbums(dsns:DsnsItem) -> [AlbumItem]{
        
        var albums = [AlbumItem]()
        
        let con = GetCommonConnect(dsns.AccessPoint)
        
        var err : DSFault!
        
        let result = con.SendRequest("album.GetMyAlbums", bodyContent: "", &err)
        
        let xml = try? AEXMLDocument(xmlData: result.dataValue)
        
        if let albs = xml?.root["Response"]["albums"].all{
            
            for album in albs{
                
                let uid = album["Uid"].stringValue
                
                let albumName = album["AlbumName"].stringValue
                
                let refGroupId = album["RefGroupId"].stringValue
                
                let photoCount = album["PhotoCount"].stringValue
                
                let previewUrl = album["Preview"].stringValue
                
                var cover : UIImage!
                
                if let imgData = try? HttpClient.Get(previewUrl){
                    if let img = UIImage(data: imgData){
                        cover = img
                    }
                }
                    
                if cover == nil{
                    cover = UIImage(named: "default photo.jpg")!
                }
                
                albums.append(AlbumItem(Cover: cover, School: dsns.AccessPoint, Context: albumName, Id: uid, RefGroupId : refGroupId, Count : photoCount))
            }
            
        }
        
        return albums
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return myAlbums.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let data = myAlbums[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("AlbumCell") as! AlbumCell
        
        cell.albumItem = data
        
        cell.cover.image = data.Cover
        
        cell.school.text = GetSchoolName(GetCommonConnect(data.School))
        
        cell.context.text = data.Context
        
        cell.count.text = "相片數 : " + data.Count
        
        let longPress = UILongPressGestureRecognizer(target: self, action: "LongPress:")
        
        longPress.minimumPressDuration = 0.5
        
        cell.addGestureRecognizer(longPress)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        let data = myAlbums[indexPath.row]
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoPreviewCtrl") as! PhotoPreviewCtrl
        
        nextView.Album = data
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func LongPress(sender:UILongPressGestureRecognizer){
        
        if sender.state == UIGestureRecognizerState.Began{
            let cell = sender.view as! AlbumCell
            
            if let album = cell.albumItem{
                
                let menu = UIAlertController(title: "要刪除相簿 : \(album.Context) 嗎?", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                
                menu.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
                
                menu.addAction(UIAlertAction(title: "是", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                    self.DeleteAlbum(album)
                }))
                
                self.presentViewController(menu, animated: true, completion: nil)
            }
            
        }
    }
    
    func DeleteAlbum(albumItem:AlbumItem){
        
        let con = GetCommonConnect(albumItem.School)
        
        var err : DSFault!
        
        con.SendRequest("album.DeleteAlbum", bodyContent: "<Request><album><Uid>\(albumItem.Id)</Uid></album></Request>", &err)
        
        self.Reload()
    }

    
    func AddAlbum(){
        
        needReload = true
        
        let creatView = self.storyboard?.instantiateViewControllerWithIdentifier("CreateAlbumViewCtrl") as! CreateAlbumViewCtrl
        
        self.navigationController?.pushViewController(creatView, animated: true)
        
    }
}

struct AlbumItem{
    var Cover : UIImage
    var School : String
    var Context : String
    var Id : String
    var RefGroupId : String
    var Count : String
}

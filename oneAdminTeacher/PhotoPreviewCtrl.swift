//
//  PhotoPreviewCtrl.swift
//  oneAdminTeacher
//
//  Created by Cloud on 1/4/16.
//  Copyright © 2016 ischool. All rights reserved.
//

import UIKit

class PhotoPreviewCtrl: UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var Album : AlbumItem!
    
    var PreviewDatas = [PreviewData]()
    var PassValues = [PreviewData]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Add, target: self, action: "AddPhoto")
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            let pds = self.GetPreviewData()
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.PreviewDatas = pds
                
                self.PassValues.removeAll(keepCapacity: true)
                self.PassValues = self.PreviewDatas.map({return $0.Clone})
                
                self.collectionView.reloadData()
            })
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func AddPhoto(){
        
        let editView = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoEditViewCtrl") as! PhotoEditViewCtrl
        
        editView.AlbumData = Album
        
        //dispatch_async(dispatch_get_main_queue()){
        self.navigationController?.pushViewController(editView, animated: true)
        //}
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return PreviewDatas.count
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        
        let data = PreviewDatas[indexPath.row]
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("photo", forIndexPath: indexPath)
        
        let imgView = cell.viewWithTag(100) as! UIImageView
        
        if data.Photo == nil {
            
            if let `catch` = PhotoCoreData.LoadPreviewData(data) {
                data.Photo = `catch`
            }
            else{
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                    
                    data.UpdatePreviewData()
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        PhotoCoreData.SaveCatchData(data)
                        
                        if let tempCell = collectionView.cellForItemAtIndexPath(indexPath){
                            
                            let tempImgView = tempCell.viewWithTag(100) as! UIImageView
                            
                            tempImgView.image = data.Photo
                        }
                    })
                })
            }
        }
        
        imgView.image = data.Photo
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        switch Global.ScreenSize.width{
        case 414 :
            return CGSizeMake((collectionView.bounds.size.width - 4) / 4, (collectionView.bounds.size.width - 4) / 4)
        case 375 :
            return CGSizeMake((collectionView.bounds.size.width - 3) / 3, (collectionView.bounds.size.width - 3) / 3)
        default :
            return CGSizeMake((collectionView.bounds.size.width - 3) / 3, (collectionView.bounds.size.width - 3) / 3)
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 1.0
    }
    
    //call when item is clicked
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        
        let data = PreviewDatas[indexPath.row]
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("PhotoDetailViewCtrl") as! PhotoDetailViewCtrl
        
        //nextView.Base = data
        nextView.PassValues = PassValues
        nextView.CurrentIndex = indexPath.row
        nextView.TeacherMode = true
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func GetPreviewData() -> [PreviewData]{
        
        var retVal = [PreviewData]()
        
        let con = GetCommonConnect(Album.School)
        
        var err : DSFault!
        
        let result = con.sendRequest("photo.GetPhotos", bodyContent: "<Request><RefAlbumId>\(Album.Id)</RefAlbumId></Request>", &err)
        
        let xml = try? AEXMLDocument(xmlData: result.dataValue)
        
        if let photots = xml?.root["Response"]["photos"].all{
            
            for photo in photots{
                
                let uid = photo["Uid"].stringValue
                let preview_url = photo["Preview"].stringValue
                let detail_url = photo["Detail"].stringValue
                
                let comment = photo["Comment"].stringValue
                
                let pd = PreviewData(dsns: Album.School, refGroupId : Album.RefGroupId, uid: uid, previewUrl: preview_url, detailUrl: detail_url)
                pd.Comment = comment
                
                retVal.append(pd)
            }
        }
        
        return retVal
    }
}

class PreviewData{
    
    var Dsns : String
    var RefGroupId : String
    var Uid : String
    var PreviewUrl : String
    var DetailUrl : String
    var Photo : UIImage!
    var Comment : String
    
    init(dsns:String,refGroupId:String,uid:String,previewUrl:String,detailUrl:String){
        Dsns = dsns
        RefGroupId = refGroupId
        Uid = uid
        PreviewUrl = previewUrl
        DetailUrl = detailUrl
        Comment = ""
    }
    
    var Clone : PreviewData{
        
        let pd = PreviewData(dsns: Dsns, refGroupId: RefGroupId, uid: Uid, previewUrl: PreviewUrl, detailUrl: DetailUrl)
        pd.Comment = Comment
        
        return pd
    }
    
    func UpdatePreviewData() -> Bool {
        
        if let nsd = try? HttpClient.Get(PreviewUrl){
            if let img = UIImage(data: nsd){
                
                Photo = img
                
                return true
            }
        }
        
        return false
    }
}

struct PhotoObj {
    var Dsns : String
    var Uid : String
}
//
//  ListViewController.swift
//  projectForExam
//
//  Created by Stanislav Korolev on 03.04.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import UIKit
import CoreImage

let dataSourceURL = URL(string:"")
private let reuseIdentifier = "cell"

class ListViewController: UITableViewController {

    
    var photos = [PhotoRecord]()
    let pendingOperations = PendingOperations()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView!.register(TableCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        fetchPhotoDetails()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchPhotoDetails() {
        let request = URLRequest(url:dataSourceURL!)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        NSURLConnection.sendAsynchronousRequest(request, queue: OperationQueue.main) {response,data,error in
            if data != nil {
                
                let datasourceDictionary = (try! PropertyListSerialization.propertyList(from: data!, options:PropertyListSerialization.MutabilityOptions.mutableContainersAndLeaves, format: nil)) as! Dictionary<String, Any>
                
                for(key, value) in datasourceDictionary {
                    let name = key
                    let url = URL(string:value as? String ?? "")
                    
                    if url != nil {
                        let photoRecord = PhotoRecord(name:name, url:url!)
                        self.photos.append(photoRecord)
                    }
                }
                
                self.tableView.reloadData()
            }
            
            if error != nil {
                let alert = UIAlertView(title:"Oops!",message:error!.localizedDescription, delegate:nil, cancelButtonTitle:"OK")
                alert.show()
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }

    // MARK: - Table view data source



    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableCell
        
        
        //1
        if cell.accessoryView == nil {
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            cell.accessoryView = indicator
        }
        let indicator = cell.accessoryView as! UIActivityIndicatorView
        
        //2
        let photoDetails = photos[indexPath.row]
        
        //3
        cell.textLabel?.text = photoDetails.name
        cell.imageView?.image = photoDetails.image
        
        //4
        switch (photoDetails.state){
        case .Filtered:
            indicator.stopAnimating()
        case .Failed:
            indicator.stopAnimating()
            cell.textLabel?.text = "Failed to load"
        case .New, .Downloaded:
            indicator.startAnimating()
            
            if (!tableView.isDragging && !tableView.isDecelerating) {
                self.startOperationsForPhotoRecord(photoDetails: photoDetails, indexPath: indexPath)
            }
        }
        return cell
    }
    
    // MARK: - scrooll
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        //1
        suspendAllOperations()
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // 2
        if !decelerate {
            loadImagesForOnscreenCells()
            resumeAllOperations()
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // 3
        loadImagesForOnscreenCells()
        resumeAllOperations()
    }
    
    //
    
    func suspendAllOperations () {
        pendingOperations.downloadQueue.isSuspended = true
        pendingOperations.filtrationQueue.isSuspended = true
    }
    
    func resumeAllOperations () {
        pendingOperations.downloadQueue.isSuspended = false
        pendingOperations.filtrationQueue.isSuspended = false
    }
    
    func loadImagesForOnscreenCells () {
        //1
        if let pathsArray = tableView.indexPathsForVisibleRows {
            //2
            var allPendingOperations = Set(pendingOperations.downloadsInProgress.keys)
            allPendingOperations = allPendingOperations.union(pendingOperations.filtrationsInProgress.keys)
            
            
            //3
            var toBeCancelled = allPendingOperations
            let visiblePaths = Set(pathsArray)
            toBeCancelled.subtract(visiblePaths)
            
            //4
            var toBeStarted = visiblePaths
            toBeStarted.subtract(allPendingOperations)
            
            // 5
            for indexPath in toBeCancelled {
                if let pendingDownload = pendingOperations.downloadsInProgress[indexPath] {
                    pendingDownload.cancel()
                }
                pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                if let pendingFiltration = pendingOperations.filtrationsInProgress[indexPath] {
                    pendingFiltration.cancel()
                }
                pendingOperations.filtrationsInProgress.removeValue(forKey: indexPath)
            }
            
            // 6
            for indexPath in toBeStarted {
                let indexPath = indexPath as IndexPath
                let recordToProcess = self.photos[indexPath.row]
                startOperationsForPhotoRecord(photoDetails: recordToProcess, indexPath: indexPath)
            }
        }
    }
    
    
    // MARK: - operation
    
    func startOperationsForPhotoRecord(photoDetails: PhotoRecord, indexPath: IndexPath){
        switch (photoDetails.state) {
        case .New:
            startDownloadForRecord(photoDetails: photoDetails, indexPath: indexPath)
        case .Downloaded:
            startFiltrationForRecord(photoDetails: photoDetails, indexPath: indexPath)
        default:
            NSLog("do nothing")
        }
    }
    
    func startDownloadForRecord(photoDetails: PhotoRecord, indexPath: IndexPath){
        //1
        if let _ = pendingOperations.downloadsInProgress[indexPath] {
            return
        }
        
        //2
        let downloader = ImageDownloader(photoRecord: photoDetails)
        //3
        downloader.completionBlock = {
            if downloader.isCancelled {
                return
            }
            DispatchQueue.main.async {
                self.pendingOperations.downloadsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        //4
        pendingOperations.downloadsInProgress[indexPath] = downloader
        //5
        pendingOperations.downloadQueue.addOperation(downloader)
    }
    
    func startFiltrationForRecord(photoDetails: PhotoRecord, indexPath: IndexPath){
        if let _ = pendingOperations.filtrationsInProgress[indexPath]{
            return
        }
        
        let filterer = ImageFiltration(photoRecord: photoDetails)
        filterer.completionBlock = {
            if filterer.isCancelled {
                return
            }
            DispatchQueue.main.async {
                self.pendingOperations.filtrationsInProgress.removeValue(forKey: indexPath)
                self.tableView.reloadRows(at: [indexPath], with: .fade)
            }
        }
        pendingOperations.filtrationsInProgress[indexPath] = filterer
        pendingOperations.filtrationQueue.addOperation(filterer)
    }
    
    
    
    
    func applySepiaFilter(image:UIImage) -> UIImage? {
        let inputImage = CIImage(data:UIImagePNGRepresentation(image)!)
        let context = CIContext(options:nil)
        let filter = CIFilter(name:"CISepiaTone")
        filter!.setValue(inputImage, forKey: kCIInputImageKey)
        filter!.setValue(0.8, forKey: "inputIntensity")
        if let outputImage = filter!.outputImage {
            let outImage = context.createCGImage(outputImage, from: outputImage.extent)
            return UIImage(cgImage: outImage!)
        }
        return nil
        
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }


}



class TableCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(){
//        self.backgroundColor = UIColor.randomLightColor()
    }
}

//
//  ViewController.swift
//  CellAndWifiTest
//
//  Created by Sean Holloway on 09/10/15.
//  Copyright (c) 2015 KnowIT. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NSURLSessionDelegate, NSURLSessionDownloadDelegate {
    
    @IBOutlet weak var startDownloadButton: UIButton!
    
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellDataUsageLabel: UILabel!
    
    @IBOutlet weak var wifiLabel: UILabel!
    @IBOutlet weak var wifiDataUsageLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var completetionPercentLabel: UILabel!
    
    let assetURL = NSURL(string: "https://download.blender.org/durian/trailer/sintel_trailer-1080p.ogv") //42.3MB
    let NSURLSessionDownloadTaskResumeData: String = ""  //Key in userInfo of an NSError received during failed download
    var bytesDownloadedOverCell = 0
    var bytesDownloadedOverWifi = 0
    var networkType: IJReachabilityType = .NotConnected
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.cellLabel.enabled = true
        self.wifiLabel.enabled = true
        activityIndicator.transform = CGAffineTransformMakeScale(1.25, 1.25);
        self.cellDataUsageLabel.text = "Cell Data Usage: 0 kB"
        self.wifiDataUsageLabel.text = "Wifi Data Usage: 0 kB"
        self.completetionPercentLabel.text = "0%"
        self.completetionPercentLabel.hidden = true
        
        networkType = IJReachability.isConnectedToNetworkOfType()
        setDataTypeLabel(networkType)
        
        IJReachability.setReachabilityChangedClosures(networkState: networkType,
            toWifi: {
                self.networkType = .WiFi
                self.setDataTypeLabel(self.networkType)
            },
            toWAN: {
                self.networkType = .WWAN
                self.setDataTypeLabel(self.networkType)
            },
            lostConnection: {
                self.networkType = .NotConnected
                self.setDataTypeLabel(self.networkType)
            }
        )
        IJReachability.startReachabilityMonitoring()
    }

    @IBAction func downloadButtonTapped(sender: UIButton) {
        activityIndicator.startAnimating()
        self.completetionPercentLabel.hidden = false

        let downloadConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: downloadConfiguration, delegate: self, delegateQueue: nil)
        let sessionDownloadTask = session.downloadTaskWithURL(assetURL!)
        sessionDownloadTask.resume()
    }
    
    // Sent when a download task that has completed a download.  The delegate should copy or move the file at the given location to a new location as it will be removed when the delegate message returns. URLSession:task:didCompleteWithError: will still be called
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        //let data = NSData(contentsOfURL: location)
        activityIndicator.stopAnimating()
        IJReachability.stopReachabilityMonitoring()
        
        dispatch_async(dispatch_get_main_queue(), {
            self.progressView.setProgress(100.0, animated: true)
        })
    }
    
    // Sent periodically to notify the delegate of download progress
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        var progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        var progressPercent = Int(progress * 100)
        
        switch networkType {
        case .WiFi:
            bytesDownloadedOverWifi += Int(bytesWritten)
        case .WWAN:
            bytesDownloadedOverCell += Int(bytesWritten)
        default:
            break
        }
        
        dispatch_async(dispatch_get_main_queue(), {
            self.progressView.setProgress(Float(progress), animated: true)
            self.completetionPercentLabel.text = String(stringInterpolationSegment: progressPercent) + "%"
            self.cellDataUsageLabel.text = "Cell Data Usage: \(self.bytesDownloadedOverCell) bytes"
            self.wifiDataUsageLabel.text = "Wifi Data Usage: \(self.bytesDownloadedOverWifi) bytes"
        })
    }
    
    // Sent when a download has been resumed. If a download failed with an error, the -userInfo dictionary of the error will contain an NSURLSessionDownloadTaskResumeData key, whose value is the resume data
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
    }
    
    func setDataTypeLabel(type: IJReachabilityType) {
        switch type {
        case .WiFi:
            self.cellLabel.textColor = UIColor.grayColor()
            self.wifiLabel.textColor = UIColor.greenColor()
        case .WWAN:
            self.cellLabel.textColor = UIColor.greenColor()
            self.wifiLabel.textColor = UIColor.grayColor()
        case .NotConnected:
            startDownloadButton.enabled = false
            self.cellLabel.textColor = UIColor.redColor()
            self.wifiLabel.textColor = UIColor.redColor()
        }
    }
}


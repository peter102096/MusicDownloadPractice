//
//  DownloadModel.swift
//  MusicDownload
//
//  Created by PeterLin on 2021/7/14.
//

import UIKit

class DownloadModel: NSObject {
    
    private weak var delegate: URLSessionDownloadDelegate?
    
    private(set) var destinationUrl: URL?
    
    init(_ delegate: URLSessionDownloadDelegate) {
        self.delegate = delegate
    }
    
    deinit {
        print("DownloadModel deinit")
    }
    
    func isFileExist(_ fileUrl: String) -> Bool? {
        guard let fileUrl = URL(string: fileUrl) else {
            print("This is an invalid URL")
            return nil
        }
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("This is an invalid docDirectoryURL")
            return nil
        }
        destinationUrl = documentsDirectoryURL.appendingPathComponent(fileUrl.lastPathComponent)
        guard destinationUrl != nil else {
            return nil
        }
        print("destinationUrl : \(destinationUrl!)")
        
        if FileManager.default.fileExists(atPath: destinationUrl!.path) {
            print("The file already exists at path")
            return true
        }
        return false
    }
    
    func downloadFile(_ fileUrl: String) {
        if destinationUrl != nil {
            if FileManager.default.fileExists(atPath: destinationUrl!.path) {
                print("The file already exists at path")
            } else {
                guard let fileUrl = URL(string: fileUrl) else {
                    print("This is an invalid URL")
                    return
                }
                let urlSession = URLSession(configuration: .default, delegate: delegate, delegateQueue: .main)
                print("urlSession delegate : \(urlSession.delegate!)")
                urlSession.downloadTask(with: fileUrl).resume()
            }
        }
    }
}

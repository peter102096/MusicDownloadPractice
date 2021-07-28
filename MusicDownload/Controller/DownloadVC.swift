//
//  DownloadVC.swift
//  MusicDownload
//
//  Created by PeterLin on 2021/7/14.
//

import UIKit
import MediaPlayer

class DownloadVC: UIViewController {
    
    @IBOutlet weak var thumbnailImgView: UIImageView!
    
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    @IBOutlet weak var loadingLB: UILabel!
    
    @IBOutlet weak var musicTitleLB: UILabel!
    
    @IBOutlet weak var musicArtistLB: UILabel!
    
    @IBOutlet weak var musicAlbumLB: UILabel!
    
    @IBOutlet weak var musicYearLB: UILabel!
    
    @IBOutlet weak var musicGenreLB: UILabel!
    
    @IBOutlet weak var playPauseBtn: UIButton!
    
    @IBOutlet weak var backwardBtn: UIButton!
    
    @IBOutlet weak var forwardBtn: UIButton!
    
    var downloadUrl = ""
    
    var player: AVAudioPlayer?

    var fileUrls: [URL] = []
    var currentIndex = 0
    
    private var model: DownloadModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Information"
        // Do any additional setup after loading the view.
        model = DownloadModel(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if downloadUrl != "" {
            backwardBtn.isHidden = true
            forwardBtn.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadingLB.text = "0.00%"
        if downloadUrl != "" {
            guard let isExist = model.isFileExist(downloadUrl) else {
                print("Something error")
                return
            }
            if !isExist {
                model.downloadFile(downloadUrl)
            } else {
                getMP3Info(model.destinationUrl!, isAutoPlay: false)
            }
        } else {
            print("downloadUrl is empty")
            guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                print("This is an invalid docDirectoryURL")
                return
            }
            guard let tmpFileUrls = try? FileManager.default.contentsOfDirectory(at: documentsDirectoryURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants, .skipsSubdirectoryDescendants]) else {
                return
            }
            self.fileUrls = tmpFileUrls
            print("fileUrls : \(fileUrls)")
            if fileUrls.count > 0 {
                getMP3Info(fileUrls.first!, isAutoPlay: false)
            } else {
                loadingView.stopAnimating()
                loadingLB.isHidden = true
            }
        }
    }

    @IBAction func playPauseBtnAction(_ sender: Any) {
        if !loadingView.isAnimating {
            if player != nil {
                if player!.isPlaying {
                    print("player is playing")
                    player?.pause()
                    playPauseBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
                } else {
                    print("player is not playing")
                    player?.play()
                    playPauseBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
                }
            }
        } else {
            print("FileUrl is null or is Downloading")
        }
    }
    
    @IBAction func backwardBtnAction(_ sender: Any) {
        if fileUrls.count == 0 {
            return
        }
        print("fileUrls.count : \(fileUrls.count)")
        if !(currentIndex - 1 < 0) {
            currentIndex = currentIndex - 1
        } else {
            currentIndex = fileUrls.count - 1
        }
        getMP3Info(fileUrls[currentIndex], isAutoPlay: true)
    }
    
    @IBAction func forwardBtnAction(_ sender: Any) {
        if fileUrls.count == 0 {
            return
        }
        print("fileUrls.count : \(fileUrls.count)")
        if !(currentIndex + 1 > fileUrls.count - 1) {
            currentIndex = currentIndex + 1
        } else {
            currentIndex = 0
        }
        getMP3Info(fileUrls[currentIndex], isAutoPlay: true)
    }
    
    func initView() {
        musicTitleLB.text = "Null"
        musicGenreLB.text = "Null"
        musicAlbumLB.text = "Null"
        musicArtistLB.text = "Null"
        musicYearLB.text = "Null"
        thumbnailImgView.image = nil
    }
    
    func getMP3Info(_ fileUrl: URL, isAutoPlay: Bool) {
        print("start show info")
        loadingView.stopAnimating()
        loadingLB.isHidden = true
        player?.pause()
        playPauseBtn.setImage(UIImage(systemName: "play.fill"), for: .normal)
        player = try? AVAudioPlayer(contentsOf: fileUrl)
        let playerItem = AVPlayerItem(url: fileUrl)
        let metadataList = playerItem.asset.metadata
        initView()
        for item in metadataList {
//            print("========================================")
//            print("key : \(item.key), value : \(item.stringValue)")
//            print("========================================")
            switch item.commonKey {
            case .commonKeyTitle?:
                musicTitleLB.text = item.stringValue ?? "Null"
            case .commonKeyType?:
                musicGenreLB.text = item.stringValue ?? "Null"
            case .commonKeyAlbumName?:
                musicAlbumLB.text = item.stringValue ?? "Null"
            case .commonKeyArtist?:
                musicArtistLB.text = item.stringValue ?? "Null"
            case .commonKeyArtwork?:
                if let data = item.dataValue, let image = UIImage(data: data) {
                    thumbnailImgView.image = image
                }
            case .none:
                if item.identifier!.rawValue.contains("TYER") || item.identifier!.rawValue.contains("TDRC") {
                    musicYearLB.text = item.stringValue ?? "Null"
                }
                break
            default: break
            }
        }
        
        if isAutoPlay {
            player?.play()
            playPauseBtn.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
    }
    
    
}

extension DownloadVC: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("didFinishDownloading")
        do {
            try FileManager.default.moveItem(at: location, to: model.destinationUrl!)
            print("File moved to documents folder")
            getMP3Info(model.destinationUrl!, isAutoPlay: false)
        } catch {
            print("error : \(error)")
        }
        
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        print("progress : \(progress)%")
        loadingLB.text = String(format: "%.2f", progress * 100)
    }
}

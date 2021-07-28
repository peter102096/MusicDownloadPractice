//
//  HomeVC.swift
//  MusicDownload
//
//  Created by PeterLin on 2021/7/14.
//

import UIKit

class HomeVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var downloadUrlTF: UITextField!
    
    var urlIsCorrect = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "PeterDemo"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let urlStr =
        "http://download.transcendcloud.com/MusicExample/sample.mp3"
        //"https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_5MG.mp3"
//        "https://github.com/peter102096/Image/blob/main/%E4%B8%96%E7%95%8C%E3%81%8B%E3%82%99%E7%B5%82%E3%82%8B%E3%81%BE%E3%81%A6%E3%82%99%E3%81%AF.mp3?raw=true"
        //"http://download.transcendcloud.com/MusicExample/sample.mp3"
        //"http://download.transcendcloud.com/MusicExample/sample.mp3"
        downloadUrlTF.text = urlStr
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    @IBAction func downloadBtnAction(_ sender: Any) {
        let vc = DownloadVC.fromStoryBoard()
        vc.downloadUrl = downloadUrlTF.text!
        push(vc: vc)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing")
        guard let _ = URL(string: textField.text!) else {
            return print("url is wrong !")
        }
        urlIsCorrect = true
    }
}


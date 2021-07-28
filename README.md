因牽扯架構會花更多時間，故未改成多線程下載

如要多線程下載，我的做法會是，建立TableView供user可新增筆數

textFieldDidEndEditing 時檢查使用者輸入的url是否符合。

然後開始下載時建立一個

let group = DispatchGroup()

for url in urls {

    let task = DispatchQueue(label: url.lastPathComponent)

    group.enter()

    task.async(group: group, qos: .default) {

        //downloadMP3

        ..

        //when mp3 download finish

        group.leave()

    }

}

group.notify(queue: .main) {

    //即可更新UI並從第一個檔案開始播放

    delegate?.allFilesDownloadFinish()
    
}

//
//  HomeViewController.swift
//  Instagram
//
//  Created by Dan Inano on 2020/10/09.
//  Copyright © 2020 dan.inano. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    // 投稿データを格納する配列
    var postArray: [PostData] = []

    // Firestoreのリスナー
    var listener: ListenerRegistration!

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        // カスタムセルを登録する
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")

        if Auth.auth().currentUser != nil {
            // ログイン済み
            if listener == nil {
                // listener未登録なら、登録してスナップショットを受信する
                let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
                listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                    if let error = error {
                        print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                        return
                    }
                    // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                    self.postArray = querySnapshot!.documents.map { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let postData = PostData(document: document)
                        return postData
                    }
                    // TableViewの表示を更新する
                    self.tableView.reloadData()
                }
            }
        } else {
            // ログイン未(またはログアウト済み)
            if listener != nil {
                // listener登録済みなら削除してpostArrayをクリアする
                listener.remove()
                listener = nil
                postArray = []
                tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        
        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        cell.commentButton.addTarget(self, action: #selector(handleCommentButton(_:forEvent:)), for: .touchUpInside)

        return cell
    }
    
    //セル内のボタンがタップされた時に呼び出されるメソッド
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent){
        print("DEBUG_PRINT: likeボタンがタップされました")
        
        //タップされたインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        //配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        //likeを更新する
        if let myid = Auth.auth().currentUser?.uid{
            //更新データを作成する
            var updateValue: FieldValue
            
            if postData.isLiked{
                //既にいいねをしている場合は解除するためにmyidを取り除くデータを更新
                updateValue = FieldValue.arrayRemove([myid])
            }else{
                //今回新たにいいねをした場合はmyidを更新すうるデータを更新する
                updateValue = FieldValue.arrayUnion([myid])
            }
            
            //likeに更新データを書き込む
            let psotRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            psotRef.updateData(["likes": updateValue])
        }
    }
    
    @objc func handleCommentButton(_ sender: UIButton, forEvent event: UIEvent){
        print("DEBUG_PRINT:commentボタンがタップされました")
        
        //タップされたインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        //配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        var alertTextField :UITextField?
        
        let alert = UIAlertController(
            title:"コメント",
            message:"コメントを入力して下さい",
            preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: {(textField:UITextField!)in
            alertTextField = textField
            _ = alertTextField?.text
        })
        
        alert.addAction(UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "送信", style: UIAlertAction.Style.default){_ in
            if let text = alertTextField?.text{
                
                let commenterName = Auth.auth().currentUser?.displayName
                
                let postedComment = postData.comment
                
                let commentText = "\(postedComment!)\(commenterName!): \(text) \n"
                
                let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
                postRef.updateData(["comment": commentText])
            }
        })
        self.present(alert,animated:true,completion: nil)
    }
    
    
}

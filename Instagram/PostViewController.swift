//
//  PostViewController.swift
//  Instagram
//
//  Created by Dan Inano on 2020/10/09.
//  Copyright © 2020 dan.inano. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD
import CLImageEditor

class PostViewController: UIViewController {
    var image:UIImage!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    //投稿ボタンをタップしたときに呼び出されるメソッド
    @IBAction func handlePostButton(_ sender: Any) {
        //JPEGに変換する
        let imageData = image.jpegData(compressionQuality: 0.75)
        //画像とデータの保存場所を定義する
        let postRef = Firestore.firestore().collection(Const.PostPath).document()
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postRef.documentID + ".jpg")
        
        //投稿処理中の表示を開始
        SVProgressHUD.show()
        //Storageに画像をアップロードする
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        imageRef.putData(imageData!,metadata: metaData){ (metaData,error) in
            if error != nil{
                //画像アップロードの失敗
                print("error!")
                SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                //投稿処理をキャンセルし先頭画面に戻る（複数のモーダル画面を一気に閉じる）
                UIApplication.shared.windows.first{ $0 .isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
            }
        }
        // FireStoreに投稿データを保存する
        let name = Auth.auth().currentUser?.displayName
        let postDic = [
            "name":name!,
            "caption": self.textField.text!,
            "comment": "",
            "date": FieldValue.serverTimestamp(),
            ] as [String: Any]
        postRef.setData(postDic)
        
        //投稿の成功をHUDで知らせる
        SVProgressHUD.showSuccess(withStatus: "投稿しました")
        //投稿が終わったため先頭画面に戻る
        UIApplication.shared.windows.first{ $0 .isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    //キャンセルボタンをタップしたときに呼び出されるメソッド
    @IBAction func handleCancelButton(_ sender: Any) {
        //加工画面に戻る
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigat

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

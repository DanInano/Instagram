//
//  ImageSelectViewController.swift
//  Instagram
//
//  Created by Dan Inano on 2020/10/09.
//  Copyright © 2020 dan.inano. All rights reserved.
//

import UIKit
import CLImageEditor

class ImageSelectViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLImageEditorDelegate{
    @IBAction func handleLibraryButton(_ sender: Any) {
        //ライブラリを指定してフォトライブラリを開く
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let pickController = UIImagePickerController()
            pickController.delegate = self
            pickController.sourceType = .photoLibrary
            self.present(pickController, animated: true, completion: nil)
        }
    }
    @IBAction func handleCameraButton(_ sender: Any) {
        //カメラを選択してカメラを開く
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let pickController = UIImagePickerController()
            pickController.delegate = self
            pickController.sourceType = .camera
            self.present(pickController, animated: true, completion: nil)
        }
    }
    @IBAction func handleCancelButton(_ sender: Any) {
        //画面を閉じる
        self.dismiss(animated: true, completion: nil)
    }
    
    //写真を選択、撮影した時に呼び出されるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if info[.originalImage] != nil{
            //撮影もしくは選択された画像を読み込む
            let image = info[.originalImage] as! UIImage
            //あとでCLImageEditorで加工する
            print("DEBUG_PRINT image = \(image) ")
            //CLImageEditorに画像を渡して編集画面を起動する
            let editor = CLImageEditor(image: image)!
            editor.delegate = self
            editor.modalPresentationStyle = .fullScreen
            picker.present(editor, animated: true, completion: nil)
        }
    }
 
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        //imageSelectViewControllerの画面を閉じてタブ画面に戻る
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    // CLImageEditorで加工が終わったときに呼ばれるメソッド
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        // 投稿画面を開く
        let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "Post") as! PostViewController
        postViewController.image = image!
        editor.present(postViewController, animated: true, completion: nil)
    }
    //編集う画面で時にに呼び出されるメソッド
    func imageEditorDidCancel(_ editor: CLImageEditor!) {
        //ImgaeSelectViewController画面を閉じてタブに戻る
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

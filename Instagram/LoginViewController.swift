//
//  LoginViewController.swift
//  Instagram
//
//  Created by Dan Inano on 2020/10/09.
//  Copyright © 2020 dan.inano. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var mailAdressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displaynameTextField: UITextField!
    
    @IBAction func handleLogiinButton(_ sender: Any) {
        if let adress = mailAdressTextField.text, let password = passwordTextField.text{
            //アドレスかパスワードどちらかが入力されていないときはなにもしない
            if adress.isEmpty || password.isEmpty {
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                return
            }
            
            //HUDで処理中を表示
            SVProgressHUD.show()
            Auth.auth().signIn(withEmail: adress, password: password){authResult, error in
                if let error = error{
                    print("DEBUG_PRINT:" + error.localizedDescription)
                    SVProgressHUD.showError(withStatus:"サインインに失敗しました")
                }
                print("DEBUG_PRINT:  ログインに成功しました")
                
                //HUDを消す
                SVProgressHUD.dismiss()
                
                //画面を閉じてタブ画面に戻る
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    @IBAction func handleCreateAccountButton(_ sender: Any) {
        if let adress = mailAdressTextField.text, let password = passwordTextField.text, let displayName = displaynameTextField.text{
            
            if adress.isEmpty || password.isEmpty || displayName.isEmpty {
                print("DEBUG_PRINT: 何かが空文字です")
                SVProgressHUD.showError(withStatus:"必要項目を入力して下さい")
                return
            }
            
            SVProgressHUD.show()
            //アドレスとパスワードでユーザを作成。作成に成功したら自動でログインする
            Auth.auth().createUser(withEmail: adress, password: password) { authResult, error in
                if let error = error{
                    //エラーがあったら原因をプリントして以降の処理を行わず終了する
                    print("DEBUG_PRINT:" + error.localizedDescription)
                    SVProgressHUD.showError(withStatus: "ユーザー作成に失敗しました")
                    return
                }
                
                print("DEBUG_PRINT: ユーザ作成に成功しました")
            }
                //表示名を設定する
                let user = Auth.auth().currentUser
                if let user = user{
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = displayName
                    changeRequest.commitChanges{error in
                        if let error = error{
                            print("DEBUG_PRINT:" + error.localizedDescription)
                            SVProgressHUD.showError(withStatus: "表示名の設定に失敗しました")
                            return
                        }
                        print("DEBUG_PRINT: [\(user.displayName!)]の設定に成功しました")
                        
                        SVProgressHUD.dismiss()
                        
                        // 画面を閉じてタブ画面に戻る
                        self.dismiss(animated: true, completion: nil)
                    }
            }
                
        }

        
    }
    /*
    override func viewDidLoad() {
        super.viewDidLoad()
    }
 */
}

//
//  PostData.swift
//  Instagram
//
//  Created by Dan Inano on 2020/10/14.
//  Copyright © 2020 dan.inano. All rights reserved.
//

import UIKit
import Firebase

class PostData: NSObject{
    var id: String
    var name: String?
    var caption: String?
    var comment: String?
    var date: Date?
    var likes: [String] = []
    var isLiked: Bool = false
    
    init(document: QueryDocumentSnapshot){
        self.id = document.documentID
        
        let postDic = document.data()
        
        self.name = postDic["name"] as? String
        
        self.caption = postDic["caption"] as? String
        
        self.comment = postDic["comment"] as? String
        
        let timestamp = postDic["date"] as? Timestamp
        self.date = timestamp?.dateValue()
        
        if let likes = postDic["likes"] as? [String]{
            self.likes = likes
        }
        
        if let myid = Auth.auth().currentUser?.uid{
            //likesの配列の中にmyidが含まれているかをもとに良いねをしたかを判断
            if self.likes.firstIndex(of: myid) != nil{
                //myidがあればいいねをしていると認識
                self.isLiked = true
            }
        }
        
        
    }
}

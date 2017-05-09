//
//  ChatScreenVC.swift
//  FireChat
//
//  Created by Tauseef Latif on 2017-04-23.
//  Copyright © 2017 Tauseef Latif. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import MobileCoreServices
import AVKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import SDWebImage

class ChatScreenVC: JSQMessagesViewController {
    
    var messages = [JSQMessage]()
    var avatarDict = [String: JSQMessagesAvatarImage]()
    var messageRef = FIRDatabase.database().reference().child("messages")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let currentUser = FIRAuth.auth()?.currentUser
        {
            self.senderId = currentUser.uid
            
            if currentUser.isAnonymous == true
            {
                self.senderDisplayName = "anonymous"
            } else
            {
                self.senderDisplayName = "\(currentUser.displayName!)"
            }
        }
        observeMessages()
    }
    
    func observeUsers(_ id: String)
    {
        FIRDatabase.database().reference().child("users").child(id).observe(.value, with: {
            snapshot in
            if let dict = snapshot.value as? [String: AnyObject]
            {
                let avatarUrl = dict["profileUrl"] as! String
                
                self.setupAvatar(avatarUrl, messageId: id)
            }
        })
        
    }
    
    func setupAvatar(_ url: String, messageId: String)
    {
        if url != "" {
            let fileUrl = URL(string: url)
            let data = try? Data(contentsOf: fileUrl!)
            let image = UIImage(data: data!)
            let userImg = JSQMessagesAvatarImageFactory.avatarImage(with: image, diameter: 30)
            self.avatarDict[messageId] = userImg
            self.collectionView.reloadData()
            
        } else {
            avatarDict[messageId] = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "profileImage"), diameter: 30)
            collectionView.reloadData()
        }
        
    }
    
    func observeMessages() {
        messageRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
            if let dict = snapshot.value as? [String: Any] {
                let mediaType = dict["mediaType"] as! String
                let senderId = dict["senderId"] as! String
                let senderName = dict["senderName"] as! String
                
                self.observeUsers(senderId)
                
                switch mediaType {
                    case "TEXT":
                        
                        let text = dict["text"] as! String
                        self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, text: text))
                    
                    case "PHOTO":
                        
//                        let fileUrl = dict["fileUr"] as! String
//                        let url = URL(string: fileUrl)
//                        guard let data = try? Data(contentsOf: url!) else {return}
//                        let picture = UIImage(data: data)
//                        let photo = JSQPhotoMediaItem(image: picture)
//                        self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: photo))
                    
                        let photo = JSQPhotoMediaItem(image: nil)
                        let fileUrl = dict["fileUrl"] as! String
                        let downloader = SDWebImageDownloader.shared()
                        downloader.downloadImage(with: URL(string: fileUrl)!, options: [], progress: nil, completed: { (image, data, error, finished) in
                            DispatchQueue.main.async(execute: {
                                photo?.image = image
                                self.collectionView.reloadData()
                            })
                        })
                        
                        self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: photo))
                        
                        if self.senderId == senderId {
                            photo?.appliesMediaViewMaskAsOutgoing = true
                        } else {
                            photo?.appliesMediaViewMaskAsOutgoing = false
                        }
                    
                    case "VIDEO":
                        
                        let fileUrl = dict["fileUrl"] as! String
                        let video = URL(string: fileUrl)
                        let videoItem = JSQVideoMediaItem(fileURL: video, isReadyToPlay: true)
                        self.messages.append(JSQMessage(senderId: senderId, displayName: senderName, media: videoItem))
                    
                        if self.senderId == senderId {
                            videoItem?.appliesMediaViewMaskAsOutgoing = true
                        } else {
                            videoItem?.appliesMediaViewMaskAsOutgoing = false
                        }
                    
                default:
                    print("Unkown data type")
                }
                
                self.collectionView.reloadData()
            }
            
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
//        messages.append(JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text))
//        collectionView.reloadData()
        
        let newMessage = messageRef.childByAutoId()
        let messageData = ["text": text, "senderId": senderId, "senderName": senderDisplayName, "mediaType": "TEXT"]
        newMessage.setValue(messageData)
        self.finishSendingMessage()
        view.endEditing(true)
        
    }
    
    func getMediaFrom(_ type: CFString) {
        print(type)
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.mediaTypes = [type as String]
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        if message.senderId == self.senderId {
            
            return bubbleFactory!.outgoingMessagesBubbleImage(with: .black)
        } else {
            
            return bubbleFactory!.incomingMessagesBubbleImage(with: .blue)
            
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.item]
        
        return avatarDict[message.senderId]
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        let message = messages[indexPath.item]
        if message.isMediaMessage {
            if let mediaItem = message.media as? JSQVideoMediaItem {
                let player = AVPlayer(url: mediaItem.fileURL)
                let playerVC = AVPlayerViewController()
                playerVC.player = player
                self.present(playerVC, animated: true, completion: nil)
            }
        }
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        
        let sheet = UIAlertController(title: "Media Messages", message: "Please select media", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (UIAlertAction) in
            
        }
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (UIAlertAction) in
            self.getMediaFrom(type: kUTTypeImage)
        }
        let videoLibrary = UIAlertAction(title: "Video Library", style: .default) { (UIAlertAction) in
            self.getMediaFrom(type: kUTTypeMovie)
        }
        
        sheet.addAction(photoLibrary)
        sheet.addAction(videoLibrary)
        sheet.addAction(cancel)
        self.present(sheet, animated: true, completion: nil)

    }
    
    func getMediaFrom(type: CFString){
        let mediaPicker = UIImagePickerController()
        mediaPicker.delegate = self
        mediaPicker.mediaTypes = [type as String]
        self.present(mediaPicker, animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func logoutTapped(_ sender: Any) {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let error {
            print(error)
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let LogInVC = storyboard.instantiateViewController(withIdentifier: "LogInVC") as! LogInVC
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.window?.rootViewController = LogInVC

    }
    
    func sendMedia(picture: UIImage?, video: URL?) {
        if let picture = picture {
            let filePath = "\(FIRAuth.auth()!.currentUser!)/\(NSDate.timeIntervalSinceReferenceDate)"
            let data = UIImageJPEGRepresentation(picture, 0.1)
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpg"
            FIRStorage.storage().reference().child(filePath).put(data!, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "damn!!")
                    return
                }
                let fileUrl = metadata?.downloadURLs?[0].absoluteString
                let newMessage = self.messageRef.childByAutoId()
                let messageData = ["fileUrl": fileUrl, "senderId": self.senderId, "senderName": self.senderDisplayName, "mediaType": "PHOTO"]
                newMessage.setValue(messageData)
            }
        } else if let video = video {
            let filePath = "\(FIRAuth.auth()!.currentUser!)/\(NSDate.timeIntervalSinceReferenceDate)"
            guard let data = try? Data(contentsOf: video) else {return}
            let metadata = FIRStorageMetadata()
            metadata.contentType = "video/mp4 "
            FIRStorage.storage().reference().child(filePath).put(data, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "damn!!")
                    return
                }
                let fileUrl = metadata?.downloadURLs?[0].absoluteString
                let newMessage = self.messageRef.childByAutoId()
                let messageData = ["fileUrl": fileUrl, "senderId": self.senderId, "senderName": self.senderDisplayName, "mediaType": "VIDEO"]
                newMessage.setValue(messageData)
            }
        }
        
    }

}

extension ChatScreenVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let picture = info[UIImagePickerControllerOriginalImage] as? UIImage {
            sendMedia(picture: picture, video: nil)
        }
        else if let video = info[UIImagePickerControllerMediaURL] as? URL {
            sendMedia(picture: nil, video: video)
        }
        
        self.dismiss(animated: true, completion: nil)
        collectionView.reloadData()
    }
}

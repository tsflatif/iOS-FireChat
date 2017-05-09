//
//  Helper.swift
//  FireChat
//
//  Created by Tauseef Latif on 2017-04-23.
//  Copyright © 2017 Tauseef Latif. All rights reserved.
//

import Foundation
import FirebaseAuth
import UIKit
import GoogleSignIn
import FirebaseDatabase

class Helper {
    static let helper = Helper()
    
    func loginAnonymousTapped() {
        
        FIRAuth.auth()?.signInAnonymously(completion: { (anonymousUser: FIRUser?, error: Error?) in
            if error == nil {
                let newUser = FIRDatabase.database().reference().child("users").child(anonymousUser!.uid)
                newUser.setValue(["displayname" : "anonymous", "id" : "\(anonymousUser!.uid)",
                    "profileUrl": ""])
                self.switchToNavigationViewController()
                
            } else {
                print(error!.localizedDescription)
                return
            }
        })
    }
    
    func logInWithGoogle(authentication: GIDAuthentication) {
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        FIRAuth.auth()?.signIn(with: credential, completion: { (user: FIRUser?, error: Error?) in
            if error == nil {
                let newUser = FIRDatabase.database().reference().child("users").child(user!.uid)
                newUser.setValue(["displayname" : "\(user!.displayName!)", "id" : "\(user!.uid)",
                    "profileUrl": "\(user!.photoURL!)"])
                
                self.switchToNavigationViewController()
            } else {
                print(user?.email ?? "nutting")
            }
        })
    }
    
    func switchToNavigationViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let naviVC = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = naviVC
    }

}

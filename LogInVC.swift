//
//  LogInVC.swift
//  FireChat
//
//  Created by Tauseef Latif on 2017-04-23.
//  Copyright © 2017 Tauseef Latif. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseAuth

class LogInVC: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {

    @IBOutlet weak var anonymousButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        anonymousButton.layer.borderWidth = 2.0
        anonymousButton.layer.borderColor = UIColor.white.cgColor
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        FIRAuth.auth()?.addStateDidChangeListener({ (auth: FIRAuth, user: FIRUser?) in
//            if user != nil {
//                Helper.helper.switchToNavigationViewController()
//            } else {
//                print("Unauthorized")
//            }
//        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func loginAnonymousTapped(_ sender: Any) {
        Helper.helper.loginAnonymousTapped()
    }

    @IBAction func googleLoginTapped(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        Helper.helper.logInWithGoogle(authentication: user.authentication)
    }
}

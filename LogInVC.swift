//
//  LogInVC.swift
//  FireChat
//
//  Created by Tauseef Latif on 2017-04-23.
//  Copyright © 2017 Tauseef Latif. All rights reserved.
//

import UIKit

class LogInVC: UIViewController {

    @IBOutlet weak var anonymousButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        anonymousButton.layer.borderWidth = 2.0
        anonymousButton.layer.borderColor = UIColor.white.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func loginAnonymousTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let naviVC = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as! UINavigationController
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.window?.rootViewController = naviVC
        
    }

    @IBAction func googleLoginTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let naviVC = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as! UINavigationController
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.window?.rootViewController = naviVC
    }
}

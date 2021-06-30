//
//  WelcomeViewController.swift
//  SmartHome
//
//  Created by Aysun Molla on 30.06.2021.
//

import UIKit
import Foundation
import Firebase

class ChatViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = K.appName
        navigationItem.hidesBackButton = true
    }
    
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
    }
    

    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

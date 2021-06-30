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
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    let db = Firestore.firestore()
    var messages: [Message] = []
    var dataService = DataService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        title = K.appName
        navigationItem.hidesBackButton = true
        
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        //loadMessages()
        //loadData()
    }
    
    func loadData() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    func loadMessages(){
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { (querySnapshot, error) in
            self.messages = []
            if let e = error {
                print(e)
            } else {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let messageSender = data[K.FStore.senderField] as? String,
                           let messageBody = data[K.FStore.bodyField] as? String {
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            self.messages.append(newMessage)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        if let cmd = messageTextField.text {
            messages.append(Message(sender: Auth.auth().currentUser?.email ?? "", body: cmd))
            messageTextField.text = ""
            let command = cmd.replacingOccurrences(of: " ", with: "%20")
            var returnData = ""
            let urlString = "\("http://127.0.0.1:5000/predict?cmd=")\(command)"
            if let url = URL(string: urlString) {
                let session = URLSession(configuration: .default)
                let task = session.dataTask(with: url) { (data, response, error) in
                    if error != nil {
                        //self.delegate?.didFailWithError(error: error!)
                        return
                    }
                    if let safeData = data {
                        if let parseData = self.parseJSON(safeData) {
                            returnData = parseData
                            self.messages.append(Message(sender: K.homeBase, body: returnData))
                            self.loadData()
                        }
                    }
                }
                task.resume()
            } else {
                messages.append(Message(sender: K.homeBase, body: "Invalid command declaration. Please try again."))
            }
            loadData()
        }
    }
    
    func parseJSON(_ data: Data) -> String? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(HomeData.self, from: data)
            
            var returnMessage = ""
            returnMessage += "Action: \(decodedData.action)\n"
            returnMessage += "Action Need: \(decodedData.action_needed)\n"
            returnMessage += "Category: \(decodedData.category)\n"
            returnMessage += "Question: \(decodedData.question)\n"
            returnMessage += "Subcategory: \(decodedData.sub_category)\n"
            returnMessage += "Time: \(decodedData.time)"
            print(returnMessage)
            return returnMessage
        } catch {
            //delegate?.didFailWithError(error: error)
            return nil
        }
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

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.body
        
        //current user message
        if message.sender == Auth.auth().currentUser?.email ?? "" {
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        } else {
            cell.rightImageView.isHidden = true
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
        return cell
    }
}

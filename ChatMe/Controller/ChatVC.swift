//
//  ChatVC.swift
//  ChatMe
//
//  Created by Eli Armstrong on 12/1/18.
//  Copyright © 2018 Eli Armstrong. All rights reserved.
//

import UIKit
import Parse

class ChatVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var chatMessages = [PFObject]()
    var timer: Timer!

    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getMessages()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(getMessages), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view.
    }
    
    @IBAction func SendMessagePressed(_ sender: Any) {
        let chatMessage = PFObject(className: "Messages")
        chatMessage["text"] = messageField.text ?? ""
        chatMessage["user"] = PFUser.current()
        chatMessage.saveInBackground { (success, error) in
            if success {
                print("The message was saved!")
                self.tableView.reloadData()
                self.messageField.text = ""
            } else if let error = error {
                print("Problem saving message: \(error.localizedDescription)")
                self.showAlert(title: "Error", message: error.localizedDescription)
            }
        }
    }
    
    func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        let chatMessage = chatMessages[indexPath.row]
        cell.messageLbl.text = chatMessage["text"] as? String
        if let user = chatMessage["user"] as? PFUser {
            // User found! update username label with username
            cell.userNameLbl.text = user.username
        } else {
            // No user found, set default username
            cell.userNameLbl.text = "🤖"
        }
        return cell
    }
    
    @objc func getMessages(){
        let query = PFQuery(className: "Messages")
        query.order(byDescending: "createdAt")
        query.includeKey("user")
        query.findObjectsInBackground { (objects, error) in
            if let error = error{
                print(error.localizedDescription)
            } else{
                self.chatMessages = objects!
                print(self.chatMessages)
                self.tableView.reloadData()
            }
        }
    }

    @IBAction func logOutPressed(_ sender: Any) {
        PFUser.logOutInBackground { (error) in
            if let error = error {
                print(error)
                self.showAlert(title: "Error", message: error.localizedDescription)
            }else{
                self.timer.invalidate()
                self.performSegue(withIdentifier: "Login", sender: nil)
            }
        }
    }
}

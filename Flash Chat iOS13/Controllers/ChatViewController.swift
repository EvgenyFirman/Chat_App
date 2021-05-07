//
//  ChatViewController.swift
//  Flash Chat iOS13


// Importing Libraries
import UIKit
import Firebase

// Chat View Controller Class with UIViewController

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    // Database Initialization
    let db = Firestore.firestore()
    
    // Messages initialization
    var messages: [Message] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.dataSource = self
        
        title = "flashChat"
        
        navigationItem.hidesBackButton = true
        
        // Registering Xib Cell
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        loadMessages()
        
    }
    
    // Load Message Function
    
    func loadMessages(){
        //Assigning Empty Array

        // Db get message collection
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { (querySnapshot,error) in
            self.messages = []
            if let e = error {
                print("There was an issue retrieving data from firestore. \(e)")
            } else  {
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                       let data = doc.data()
                        if let messageSender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String {
                            let newMessage = Message(sender: messageSender, text: messageBody)
                            self.messages.append(newMessage)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                                self.messageTextfield.text = ""
                               
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func logOutButton(_ sender: UIBarButtonItem) {
        
        do {
            // Initializing signOut method
            try Auth.auth().signOut()
            // Pop up to basic homescreen
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    // Mail pressed button
    
    @IBAction func sendPressed(_ sender: UIButton) {
        // Verifying message text and message sender
        if let messageBody = messageTextfield.text ,let messageSender = Auth.auth().currentUser?.email {
            // Putting data to database
            db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.senderField: messageSender, K.FStore.bodyField: messageBody,K.FStore.dateField: Date().timeIntervalSince1970]) { (error) in
                
                if let e = error {
                    print("This was an issue saving data to firestore \(e)")
                } else {
                    print ("Succesfully saved data")
                }
            }
            
        }
    }
}
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath ) as! MessageCell
        cell.label.text = message.text
        
        // This is a message from authorized sender
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBuble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor.black
        } else {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.messageBuble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor.black
        }
        
        return cell
    }
    
    
}

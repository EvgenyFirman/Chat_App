//
//  WelcomeViewController.swift
//  Flash Chat iOS13
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var charIndex = 0.0
        titleLabel.text = ""
        let label = "⚡️FlashChat"
        for letter in label {
            print(letter)
            Timer.scheduledTimer(withTimeInterval: 0.2 * charIndex, repeats: false) { (timer) in
                self.titleLabel.text?.append(letter)
            }
            charIndex += 1
        }
       
    }
    

}

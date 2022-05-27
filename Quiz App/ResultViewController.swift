//
//  ResultViewController.swift
//  Quiz App
//
//  Created by Chris Boshoff on 2022/02/24.
//

import UIKit

protocol ResultViewControllerProtocol {
    func dialogDismissed()
}

class ResultViewController: UIViewController {

    
    @IBOutlet weak var dimView: UIView!
    @IBOutlet weak var dialogView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var feedBackLabel: UILabel!
    @IBOutlet weak var dismissButton: UIButton!
    
    var titleText = ""
    var feedbackText = ""
    var buttonText = ""
    
    var delegate: ResultViewControllerProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Round the dialog box corners
        dialogView.layer.cornerRadius = 10
               
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Now that the elements has loaded, set the text
        titleLabel.text = titleText
        feedBackLabel.text = feedbackText
        dismissButton.setTitle(buttonText, for: .normal)
        
        
        // Hide the UI elements
        dimView.alpha = 0
        titleLabel.alpha = 0
        feedBackLabel.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        // Fade in the dimview
        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
            self.dimView.alpha = 1
            self.titleLabel.alpha = 1
            self.feedBackLabel.alpha = 1
        }, completion: nil)

    }
    
    @IBAction func dismissTapped(_ sender: Any) {
        
        // Fade out the dim view and then dismiss the popup
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            
            self.dimView.alpha = 1
        }) { (completed) in
            // Dismiss the popup
            self.dismiss(animated: true, completion: nil)
            
            // Notify delegate that the popup was dismissed
            self.delegate?.dialogDismissed()
        }

        
        
       
    }
    
}

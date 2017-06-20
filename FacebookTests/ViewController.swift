//
//  ViewController.swift
//  FacebookTests
//
//  Created by Admin on 03.05.17.
//  Copyright © 2017 grapes-studio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var lbStatus : UILabel!
    
    //facebook wrapper
    var facebook : Facebook = Facebook()
    
    
    /// Login with facebook
    @IBAction func btLoginFBAction() {
        facebook.getAuthToken { (token, error) in
            //process login status
            guard let err = (error as NSError?) else {
                self.lbStatus.text = "authorized"
                return
            }
            if (err.code == 1) {
                self.lbStatus.text = "cancelled"
            } else {
                self.lbStatus.text = err.localizedDescription
            }
        }
    }


}


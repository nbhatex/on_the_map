//
//  ViewController.swift
//  On the Map
//
//  Created by Narasimha Bhat on 27/01/16.
//  Copyright © 2016 Narasimha Bhat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var loginTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var messageTextField: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let userManager = UserManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapSignUp")
        signUpLabel.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(animated: Bool) {
        activityIndicator.hidden = true
    }
    
    func tapSignUp(){
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signin.")!)
    }
    

    @IBAction func clickLogin(sender: AnyObject) {
        
        messageTextField.text = ""
        
        let appDelegate = (UIApplication.sharedApplication().delegate as? AppDelegate)!

        guard let text = loginTextfield.text where !text.isEmpty else  {
            appDelegate.showAlert(self,title: "Invalid input",message: "Email can not be empty")
            return
        }
        guard let ptext = passwordTextfield.text where !ptext.isEmpty else {
            appDelegate.showAlert(self,title: "Invalid input", message: "Password can not be empty")
            return
        }
        
        
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        userManager.login(loginTextfield.text!,password: passwordTextfield.text!,sucess: {(parsedData) in
            
            print(parsedData)
            let userId = parsedData["account"]!["key"] as? String
            appDelegate.userId = userId
            print(userId)
            self.userManager.getUserData(userId!,sucess: {(parsedUserData) in
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.lastName = parsedUserData["user"]!!["last_name"] as? String
                appDelegate.firstName = parsedUserData["user"]!!["first_name"] as? String
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.stopAndHideActivityIndicator()
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                    self.presentViewController(controller, animated: true, completion: nil)
                })
                
                },fail: self.handleFailure)
        }, fail: self.handleFailure
        )
        
        
    }
    
    @IBAction func loginWithFacebook(sender: UIButton) {
        userManager.loginWithFacebook()
        
    }
    func handleFailure(message:String) {
        dispatch_async(dispatch_get_main_queue()) {
            self.stopAndHideActivityIndicator()
            self.messageTextField.text = message
        }
    }
    
    func stopAndHideActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }

}


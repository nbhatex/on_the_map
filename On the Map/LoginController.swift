//
//  ViewController.swift
//  On the Map
//
//  Created by Narasimha Bhat on 27/01/16.
//  Copyright © 2016 Narasimha Bhat. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController {

    @IBOutlet weak var loginTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let userManager = UserManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: "tapSignUp")
        signUpLabel.addGestureRecognizer(tapGesture)
        messageLabel.numberOfLines = 0
    }
    
    override func viewWillAppear(animated: Bool) {
        activityIndicator.hidden = true
    }
    
    func tapSignUp(){
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signin.")!)
    }
    

    @IBAction func clickLogin(sender: AnyObject) {
        
        messageLabel.text = ""
        
        let appDelegate = (UIApplication.sharedApplication().delegate as? AppDelegate)!

        guard let text = loginTextfield.text where !text.isEmpty else  {
            appDelegate.showAlert(self,title: "Invalid input",message: "Email can not be empty")
            return
        }
        guard let ptext = passwordTextfield.text where !ptext.isEmpty else {
            appDelegate.showAlert(self,title: "Invalid input", message: "Password can not be empty")
            return
        }
        
        startActivityIndicator()
        userManager.login(loginTextfield.text!,password: passwordTextfield.text!,success: self.handleLoginSuccess, fail: self.handleFailure)
    }
    
    @IBAction func loginWithFacebook(sender: UIButton) {
        messageLabel.text = ""
        
        let appDelegate = (UIApplication.sharedApplication().delegate as? AppDelegate)!
        
        guard let text = loginTextfield.text where text.isEmpty else  {
            appDelegate.showAlert(self,title: "Invalid input",message: "Did not specify exactly one credential")
            return
        }
        guard let ptext = passwordTextfield.text where ptext.isEmpty else {
            appDelegate.showAlert(self,title: "Invalid input", message: "Did not specify exactly one credential")
            return
        }
        
        let fbLoginManager  = FBSDKLoginManager()
        fbLoginManager.logInWithReadPermissions(["public_profile"], fromViewController: self, handler: {(facebookResult, facebookError) -> Void in
            guard facebookError == nil else {
                self.handleFailure(facebookError.localizedDescription)
                return
            }
            guard !facebookResult.isCancelled else {
                self.handleFailure("Login Cancelled")
                return
            }
            self.startActivityIndicator()
            self.userManager.loginWithFacebook(FBSDKAccessToken.currentAccessToken().tokenString,success: self.handleLoginSuccess,fail: self.handleFailure)
        })
        
        
    }
    
    func handleLoginSuccess(parsedData:[String:AnyObject]) {
        print(parsedData)
        let appDelegate = (UIApplication.sharedApplication().delegate as? AppDelegate)!
        let userId = parsedData["account"]!["key"] as? String
        appDelegate.userId = userId
        userManager.getUserData(userId!,success: {(parsedUserData) in
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.lastName = parsedUserData["user"]!["last_name"] as? String
            appDelegate.firstName = parsedUserData["user"]!["first_name"] as? String
            
            dispatch_async(dispatch_get_main_queue(), {
                self.stopAndHideActivityIndicator()
                let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
                self.presentViewController(controller, animated: true, completion: nil)
            })
            
            },fail: self.handleFailure)
    }
    func handleFailure(message:String) {
        dispatch_async(dispatch_get_main_queue()) {
            self.stopAndHideActivityIndicator()
            self.messageLabel.text = message
        }
    }
    
    func startActivityIndicator() {
        view.alpha = 0.5
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func stopAndHideActivityIndicator() {
        view.alpha = 1.0
        activityIndicator.stopAnimating()
        activityIndicator.hidden = true
    }

}


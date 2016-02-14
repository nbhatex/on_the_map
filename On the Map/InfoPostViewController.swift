//
//  InfoPostViewController.swift
//  On the Map
//
//  Created by Narasimha Bhat on 01/02/16.
//  Copyright © 2016 Narasimha Bhat. All rights reserved.
//

import UIKit
import MapKit

class InfoPostViewController: UIViewController {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var urlTextField: UITextField!
    
    @IBOutlet weak var placeTextfield: UITextField!
    
    @IBOutlet weak var buttonHolderView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var info:[String:AnyObject]!
    var savedButtonHolderTop:CGFloat!
    var savedButtonHolderBottom:CGFloat!
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        returnToTabView()
    }
    
    @IBOutlet weak var buttonHolderTop: NSLayoutConstraint!
    @IBOutlet weak var buttonHolderBottom: NSLayoutConstraint!
    
    @IBAction func findOnMap(sender: UIButton) {
        let appDelegate = (UIApplication.sharedApplication().delegate as? AppDelegate)!
        
        if sender.currentTitle == "Find on the Map" {

            guard let text = placeTextfield.text where !text.isEmpty else  {
                appDelegate.showAlert(self, title: "Find location", message: "Please provide location value")
                return
            }
            
            let geocoder = CLGeocoder()
            showActivityIndicator()
            geocoder.geocodeAddressString(placeTextfield.text!, completionHandler: {(placemarks,error) in
                self.hideActivityIndicator()
                guard error == nil else {
                    appDelegate.showAlert(self, title: "Find location", message: "Could not find the location \(self.placeTextfield.text!)")
                    return
                }
                self.buttonHolderView.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.1)
                self.mapView.hidden=false
                self.urlTextField.hidden=false
                self.questionLabel.hidden=true
                let annotation = MKPointAnnotation()
                let coordinate = placemarks?.first?.location?.coordinate
                annotation.coordinate = coordinate!
                annotation.title = self.placeTextfield.text
                self.mapView.addAnnotation(annotation)
                
                let region = MKCoordinateRegionMakeWithDistance(
                    coordinate!, 20000, 20000)
                
                self.mapView.setRegion(region, animated: true)
                
                self.info["mapString"]=self.placeTextfield.text
                self.info["latitude"] = coordinate?.latitude
                self.info["longitude"] = coordinate?.longitude
                let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
                self.info["firstName"] = appDelegate?.firstName
                self.info["lastName"] = appDelegate?.lastName
                self.info["uniqueKey"] = appDelegate?.userId
                sender.setTitle("Submit", forState: .Normal)
                
            })
        } else {
            guard let text = urlTextField.text where !text.isEmpty else  {
                appDelegate.showAlert(self,title: "Invalid input",message: "Pleave provide the URL")
                return
            }
            
            info["mediaURL"] = urlTextField.text
            let studentManager = StudentManager()
            let studentInfo = StudentInformation(dictionary: info)
            self.showActivityIndicator()
            studentManager.submitStudentInformation(studentInfo, success: {(data) in
                dispatch_async(dispatch_get_main_queue(), {
                    self.hideActivityIndicator()
                    sender.setTitle("Find on the Map", forState: .Normal)
                    self.returnToTabView()
                })
                
                }, fail: {(message) in
                    dispatch_async(dispatch_get_main_queue(), {
                        self.hideActivityIndicator()
                        appDelegate.showAlert(self, title: "Submit Location", message: message)
                    })
            })
        }
        
    }
    
    func returnToTabView() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        questionLabel.lineBreakMode = .ByWordWrapping
        questionLabel.numberOfLines = 0
        urlTextField.hidden = true
        
        info = [String:AnyObject]()
        activityIndicator.hidesWhenStopped = true
        subscribeToKeyBoardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeYoKeyBoardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: "stopEditing")
        view.addGestureRecognizer(tapGesture)
    }
    
    func stopEditing() {
        view.endEditing(true)
    }
    
    func showActivityIndicator() {
        view.alpha = 0.5
        view.endEditing(true)
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        view.alpha = 1.0
        activityIndicator.stopAnimating()
    }
    
    func keyBoardWillShow(notification:NSNotification) {
        savedButtonHolderTop = buttonHolderTop.constant
        savedButtonHolderBottom = buttonHolderBottom.constant
        print(buttonHolderBottom.constant)
        buttonHolderTop.constant = placeTextfield.frame.origin.y + placeTextfield.frame.height + 8
        buttonHolderBottom.constant = getKeyboardHeight(notification)
    }
    func keyBoardWillHide(notification:NSNotification) {
        if let num = savedButtonHolderTop {
            buttonHolderTop.constant = num
            savedButtonHolderTop = nil
        }
        if let num = savedButtonHolderBottom {
            buttonHolderBottom.constant = num
            savedButtonHolderBottom = nil
        }
    }
    
    func subscribeToKeyBoardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyBoardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    func unsubscribeYoKeyBoardNotifications(){
        NSNotificationCenter.defaultCenter().removeObserver(self,name: UIKeyboardWillShowNotification,object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,name: UIKeyboardWillHideNotification,object: nil)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userinfo = notification.userInfo
        let keyboardSize = userinfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
}

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
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        returnToTabView()
    }
    
    @IBAction func findOnMap(sender: UIButton) {
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        
        if sender.currentTitle == "Find on the Map" {

            guard let text = placeTextfield.text where !text.isEmpty else  {
                appDelegate?.showAlert(self, title: "Find location", message: "Please provide location value")
                return
            }
            
            let geocoder = CLGeocoder()
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
            geocoder.geocodeAddressString(placeTextfield.text!, completionHandler: {(placemarks,error) in
                self.activityIndicator.hidden = true
                self.activityIndicator.stopAnimating()
                guard error == nil else {
                    appDelegate?.showAlert(self, title: "Find location", message: "Could not find the location \(self.placeTextfield.text!)")
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
            info["mediaURL"] = urlTextField.text
            let studentManager = StudentManager()
            let studentInfo = StudentInformation(dictionary: info)
            studentManager.submitStudentInformation(studentInfo, success: {(data) in
                dispatch_async(dispatch_get_main_queue(), {
                    sender.setTitle("Find on the Map", forState: .Normal)
                    self.returnToTabView()
                })
                
                }, fail: {(message) in
                    dispatch_async(dispatch_get_main_queue(), {
                        appDelegate?.showAlert(self, title: "Submit Location", message: message)
                    })
            })
        }
        
    }
    
    func returnToTabView() {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController")
        self.presentViewController(controller!, animated: true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        questionLabel.lineBreakMode = .ByWordWrapping
        questionLabel.numberOfLines = 0
        urlTextField.hidden = true
        
        info = [String:AnyObject]()
        activityIndicator.hidden = true
    }
}

//
//  MapController.swift
//  On the Map
//
//  Created by Narasimha Bhat on 28/01/16.
//  Copyright © 2016 Narasimha Bhat. All rights reserved.
//

import UIKit
import MapKit



class MapController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let studentManager = StudentManager()
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        mapView.delegate = self
        studentManager.getStudentInformations(false,sucess: processData,fail: handleFailure)
    }
    
    @IBAction func logOut(sender: UIBarButtonItem) {
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        appDelegate!.logOut(self)
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        studentManager.getStudentInformations(true,sucess: processData,fail: handleFailure)
    }
    
    func handleFailure(message:String) {
        dispatch_async(dispatch_get_main_queue()) {
            let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
            appDelegate?.showAlert(self, title: "Get Student Info", message: message)
        }
    }
    
    func processData(studentLocations: [StudentInformation]){
        var annotations = [MKPointAnnotation]()
        for studentLocation in studentLocations {
            let lat = CLLocationDegrees(studentLocation.latitude)
            let long = CLLocationDegrees(studentLocation.longitude)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(studentLocation.firstName) \(studentLocation.lastName)"
            annotation.subtitle = studentLocation.mediaURL
            annotations.append(annotation)
        }
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            print(self.mapView.annotations.count)
            for annotation in self.mapView.annotations {
                self.mapView.removeAnnotation(annotation)
            }
            self.mapView.addAnnotations(annotations)
        }
        
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier("pin")
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView!.canShowCallout = true
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            let urlString = annotationView.annotation!.subtitle!!
            let url:NSURL = (urlString.hasPrefix("http://") ? NSURL(string:urlString) : NSURL(string:"http://\(urlString)"))!
            app.openURL(url)
        }
    }
}
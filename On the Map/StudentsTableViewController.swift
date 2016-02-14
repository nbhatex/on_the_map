//
//  StudentsTableViewController.swift
//  On the Map
//
//  Created by Narasimha Bhat on 30/01/16.
//  Copyright © 2016 Narasimha Bhat. All rights reserved.
//

import UIKit

class StudentsTableViewController: UITableViewController {
    
    var studentInformations: [StudentInformation]!
    let studentManager = StudentManager()

    
    @IBAction func logOut(sender: UIBarButtonItem) {
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        appDelegate!.logOut(self)
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        studentManager.getStudentInformations(true, sucess: processData, fail: handleFailure)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        studentManager.getStudentInformations(false, sucess: processData, fail: handleFailure)
    }
    
    func processData(studentInformations:[StudentInformation]) {
        dispatch_async(dispatch_get_main_queue(), {
            self.studentInformations = studentInformations
            self.tableView.reloadData()
        })
    }

    func handleFailure(message:String) {
        dispatch_async(dispatch_get_main_queue(), {
            let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
            appDelegate?.showAlert(self, title: "Get Student Info", message: message)
        })
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("studentLocationCell")
        if(cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Value2, reuseIdentifier: "studentLocationCell")
        }
        let studentLocation = studentInformations[indexPath.row]
        cell?.imageView?.image = UIImage(named: "pinIcon")
        cell?.textLabel?.text = "\(studentLocation.firstName) \(studentLocation.lastName)"
        cell?.detailTextLabel?.text = studentLocation.mediaURL
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor(red: 230.0/255.0, green: 247.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        }
        
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let students = studentInformations {
            return students.count
        }
        return 0
    }
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let urlString = studentInformations[indexPath.row].mediaURL
        let url:NSURL = (urlString.hasPrefix("http://") ? NSURL(string:urlString) : NSURL(string:"http://\(urlString)"))!
        UIApplication.sharedApplication().openURL(url)
    }
}
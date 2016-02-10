//
//  StudentManager.swift
//  On the Map
//
//  Created by Narasimha Bhat on 03/02/16.
//  Copyright © 2016 Narasimha Bhat. All rights reserved.
//

import Foundation

class StudentManager {
    
    func getStudentInformations(refresh:Bool, sucess:([StudentInformation])->(), fail: (String) ->()) {
        
        if !StudentInformation.studentInformations.isEmpty && !refresh {
            let studentInformations = StudentInformation.studentInformations
            sucess(studentInformations)
            return
        }
        
        let request = getRequest()
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard error == nil else {
                fail((error?.localizedDescription)!)
                return
            }
            guard let statusCode = ( response as? NSHTTPURLResponse )?.statusCode where statusCode >= 200 && statusCode < 300 else {
                fail("API request failed with error code")
                return
            }
            var parsedObject:AnyObject
            do{
                parsedObject = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
            } catch {
                fail("Error while parsing")
                return
            }
            let results = parsedObject["results"] as! [[String : AnyObject]]
            let studentInfos = StudentInformation.getStudentInformationsFromResutl(results)
            sucess(studentInfos)
        }
        task.resume()
    }
    
    func submitStudentInformation(info: StudentInformation,success:(NSData)->(),fail:(String)->()) {
        let request = getRequest()
        
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.HTTPBody = info.toJson()
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard error == nil else {
                fail((error?.localizedDescription)!)
                return
            }
            guard let statusCode = ( response as? NSHTTPURLResponse )?.statusCode where statusCode >= 200 && statusCode < 300 else {
                fail("API request to backend failed")
                return
            }
            success(data!)
        }
        task.resume()
    }
    
    func getRequest() -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        return request
    }
    
    
}
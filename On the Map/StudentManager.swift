//
//  StudentManager.swift
//  On the Map
//
//  Created by Narasimha Bhat on 03/02/16.
//  Copyright © 2016 Narasimha Bhat. All rights reserved.
//

import Foundation

let APP_ID_VALUE = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
let API_KEY_VALUE = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
let APP_ID_KEY = "X-Parse-Application-Id"
let API_KEY_KEY = "X-Parse-REST-API-Key"
let API_URL = "https://api.parse.com/1/classes/StudentLocation"

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
            let result = self.checkIfRequestFailed(response,error: error)
            guard result.failed == false else {
                fail(result.errorMessage)
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
            let result = self.checkIfRequestFailed(response,error: error)
            guard result.failed == false else {
                fail(result.errorMessage)
                return
            }
            success(data!)
        }
        task.resume()
    }
    
    func checkIfRequestFailed(response:NSURLResponse?,error:NSError?) ->(failed:Bool,errorMessage:String) {
        var errorMessage = "API request to backend failed"
        guard error == nil else {
            errorMessage = (error?.localizedDescription)!
            return(true,errorMessage)
        }
        guard let statusCode = ( response as? NSHTTPURLResponse )?.statusCode where statusCode >= 200 && statusCode < 300 else {
            return(true,errorMessage)
        }
        return(false,"")
    }
    
    func getRequest() -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: API_URL)!)
        request.addValue(APP_ID_VALUE, forHTTPHeaderField: APP_ID_KEY)
        request.addValue(API_KEY_VALUE, forHTTPHeaderField:API_KEY_KEY )
        return request
    }
    
    
}
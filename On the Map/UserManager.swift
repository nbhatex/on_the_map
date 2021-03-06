//
//  UserManager.swift
//  On the Map
//
//  Created by Narasimha Bhat on 03/02/16.
//  Copyright © 2016 Narasimha Bhat. All rights reserved.
//

import Foundation


class UserManager {
    let SESSION_API_URL = "https://www.udacity.com/api/session"
    let USERS_API_BASE_URL = "https://www.udacity.com/api/users/"
    
    let session = NSURLSession.sharedSession()
    
    func login(username:String,password:String,success:([String:AnyObject])-> (), fail:(String)->()) {
        let url = NSURL(string: SESSION_API_URL)
        
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = [ "udacity" : [ "username" : "\(username)", "password": "\(password)"]]
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(body, options: .PrettyPrinted)
        } catch {
            return
        }
        processRequest(request,success: success,fail: fail)
        
    }
    
    func loginWithFacebook(token:String,success:([String:AnyObject])->(),fail:(String)->()) {
        let request = NSMutableURLRequest(URL: NSURL(string: SESSION_API_URL)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"facebook_mobile\": {\"access_token\": \"\(token)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        processRequest(request,success: success,fail: fail)
    }
    
    func getUserData(userId:String,success:([String:AnyObject])->(),fail:(String)->()) {
        let request = NSMutableURLRequest(URL: NSURL(string: "\(USERS_API_BASE_URL)\(userId)")!)
        processRequest(request,success: success,fail: fail)
    }
    
    func logout(success:([String:AnyObject])->(),fail:(String)->()) {
        let request = NSMutableURLRequest(URL: NSURL(string: SESSION_API_URL)!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        processRequest(request,success: success,fail: fail)
    }
    
    func processRequest(request:NSMutableURLRequest,success:([String:AnyObject])->(),fail:(String)->()) {
        
        let task = session.dataTaskWithRequest(request){ (data,response,error) in
            let result = self.checkIfRequestFailed(response, error: error)
            guard !result.failed else {
                fail(result.errorMessage)
                return
            }
            self.processData(data, success: success, fail: fail)
            
        }
        task.resume()
    }
    
    
    func checkIfRequestFailed(response:NSURLResponse?,error:NSError?) -> (failed:Bool,errorMessage:String) {
        
        var errorMessage:String = "Request to backend failed"
        guard error == nil else {
            if let message = error?.localizedDescription {
                errorMessage = message
            }
            return (true,errorMessage)
        }
        let httpResponse = response as? NSHTTPURLResponse
        guard let sCode = httpResponse?.statusCode where sCode != 403 else {
            errorMessage = "Authentication failed: Invalid Credentials"
            return (true,errorMessage)
        }
        
        guard let statusCode = httpResponse?.statusCode where statusCode >= 200 && statusCode <= 299 else {
            return (true,errorMessage)
        }
        
        return (false,"")
    }
    
    func processData(data:NSData?,success:([String:AnyObject])->(),fail:(String)->()) {
        let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
        
        var parsedData:[String:AnyObject]
        do {
            parsedData = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments) as! [String : AnyObject]
        } catch {
            fail("Unable to parse the response from back end")
            return
        }
        
        success(parsedData)
    }
}
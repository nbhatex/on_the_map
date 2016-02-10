//
//  UserManager.swift
//  On the Map
//
//  Created by Narasimha Bhat on 03/02/16.
//  Copyright © 2016 Narasimha Bhat. All rights reserved.
//

import Foundation

class UserManager {
    
    func login(username:String,password:String,sucess:([String:AnyObject])-> (), fail:(String)->()) {
        let urlString = "https://www.udacity.com/api/session"
        let url = NSURL(string: urlString)
        
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
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request){ (data,response,error) in
            guard error == nil else {
                if let message = error?.localizedDescription {
                    fail(message)
                } else {
                    fail("Request to backend failed")
                }
                return
            }
            let httpResponse = response as? NSHTTPURLResponse
            guard let sCode = httpResponse?.statusCode where sCode != 403 else {
                fail("Authentication failed: Invalid Credentials")
                return
            }
            
            guard let statusCode = httpResponse?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print(String(data: data!, encoding: NSUTF8StringEncoding))
                fail("Request to backend failed")
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            
            var parsedData:[String:AnyObject]
            do {
                parsedData = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments) as! [String : AnyObject]
            } catch {
                fail("Unable to parse the response from back end")
                return
            }
            
            sucess(parsedData)
        }
        task.resume()

    }
    
    func loginWithFacebook() {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"facebook_mobile\": {\"access_token\": \"DADFMS4SN9e8BAD6vMs6yWuEcrJlMZChFB0ZB0PCLZBY8FPFYxIPy1WOr402QurYWm7hj1ZCoeoXhAk2tekZBIddkYLAtwQ7PuTPGSERwH1DfZC5XSef3TQy1pyuAPBp5JJ364uFuGw6EDaxPZBIZBLg192U8vL7mZAzYUSJsZA8NxcqQgZCKdK4ZBA2l2ZA6Y1ZBWHifSM0slybL9xJm3ZBbTXSBZCMItjnZBH25irLhIvbxj01QmlKKP3iOnl8Ey;\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                // Handle error...
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        task.resume()
    }
    
    func getUserData(userId:String,sucess:(AnyObject)->(),fail:(String)->()) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(userId)")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard error == nil else {
                fail("Request to get userdata failed")
                return
            }
            let httpResponse = response as? NSHTTPURLResponse
            guard let statusCode = httpResponse?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print(String(data: data!, encoding: NSUTF8StringEncoding))
                fail("Request to backend failed")
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            
            var parsedData:AnyObject
            do {
                parsedData = try NSJSONSerialization.JSONObjectWithData(newData, options: .AllowFragments)
            } catch {
                fail("Unable to parse the response from back end")
                return
            }
            sucess(parsedData)
        }
        task.resume()
    }
    
    func logout(success:(NSData)->(),fail:(String)->()) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            guard error == nil else {
                fail((error?.localizedDescription)!)
                return
            }
            let httpResponse = response as? NSHTTPURLResponse
            guard let statusCode = httpResponse?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                print(String(data: data!, encoding: NSUTF8StringEncoding))
                fail("Request to backend failed")
                return
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            success(newData)
            print(NSString(data: newData, encoding: NSUTF8StringEncoding))
        }
        task.resume()
    }
    
}
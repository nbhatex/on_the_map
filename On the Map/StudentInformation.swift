//
//  StudentLocation.swift
//  On the Map
//
//  Created by Narasimha Bhat on 29/01/16.
//  Copyright © 2016 Narasimha Bhat. All rights reserved.
//

import Foundation

let DATE_FORMAT = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
let dateFormatter = NSDateFormatter()


struct StudentInformation {
    
    static var studentInformations = [StudentInformation]()
    
    var objecId:String
    var uniqueKey:String
    var firstName:String
    var lastName:String
    var mapString:String
    var mediaURL:String
    var latitude:Float
    var longitude:Float
    var createdAt:NSDate
    var updatedAt:NSDate
    
    init(dictionary: [String : AnyObject]){
        if let id = dictionary["objectId"] {
            objecId = id as! String
        } else {
            objecId = ""
        }
        
        uniqueKey = dictionary["uniqueKey"] as! String
        firstName = dictionary["firstName"] as! String
        lastName = dictionary["lastName"] as! String
        mapString = dictionary["mapString"] as! String
        mediaURL = dictionary["mediaURL"] as! String
        latitude = dictionary["latitude"] as! Float
        longitude = dictionary["longitude"] as! Float
        dateFormatter.dateFormat = DATE_FORMAT
        if let cat = dictionary["createdAt"] {
            createdAt = dateFormatter.dateFromString( cat as! String)!
        } else {
            createdAt = NSDate()
        }
        if let uat = dictionary["updatedAt"] {
            updatedAt = dateFormatter.dateFromString(uat as! String)!
        } else {
            updatedAt = NSDate()
        }
        
    }
    
    static func getStudentInformationsFromResutl(results: [[String : AnyObject]]) -> [StudentInformation] {
        studentInformations = [StudentInformation]()
        for result in results {
            studentInformations.append(StudentInformation(dictionary: result ))
        }
        studentInformations.sortInPlace({ return $0.updatedAt.compare($1.updatedAt) == NSComparisonResult.OrderedDescending })

        return studentInformations
    }
    
    func toJson() -> NSData? {
        let body = [
            "uniqueKey" : uniqueKey,
            "firstName" : firstName,
            "lastName" : lastName,
            "mapString" : mapString,
            "mediaURL" : mediaURL,
            "latitude" : latitude,
            "longitude" : longitude
        ]
        do {
            let json = try NSJSONSerialization.dataWithJSONObject(body, options: .PrettyPrinted)
            return json
        } catch {
            return nil
        }
    }
}
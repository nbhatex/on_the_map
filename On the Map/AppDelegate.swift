//
//  AppDelegate.swift
//  On the Map
//
//  Created by Narasimha Bhat on 27/01/16.
//  Copyright © 2016 Narasimha Bhat. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var lastName:String!
    var firstName:String!
    var userId:String!

    func showAlert(parent:UIViewController,title:String,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
            // Do nothing
        }))
        parent.presentViewController(alert, animated: true, completion: nil)
    }
    
    func logOut(sender:UIViewController) {
        let userManager = UserManager()
        userManager.logout({(data) in
            dispatch_async(dispatch_get_main_queue()) {
                let controller = sender.storyboard!.instantiateViewControllerWithIdentifier("LoginController")
                sender.presentViewController(controller, animated: true, completion: nil)
            }
            },fail : {(message) in
                dispatch_async(dispatch_get_main_queue()) {
                    self.showAlert(sender, title: "Failed to logout", message: message)
                }
        })
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}


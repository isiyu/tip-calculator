//
//  AppDelegate.swift
//  TipCalc
//
//  Created by Siyu Song on 12/18/14.
//  Copyright (c) 2014 siyu. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var initialBillValue:Float = 0.0
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        println("application will resign active")
        let date = NSDate()
        println(date)
        var defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject( date, forKey: "last_active_nsdate")
        //defaults.setObject(storedBillAmount , forKey: "last_billAmount")
        defaults.synchronize()
        
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
        
        let cur_date = NSDate()
        var time_to_reset: Int = 5
        var defaults = NSUserDefaults.standardUserDefaults()
        var last_active_date: AnyObject? = defaults.valueForKey("last_active_nsdate")
        
        if last_active_date == nil {
            // if no last active date found
            // set the bill amount to 0
            initialBillValue = 0.0
            return
        }
        
        let interval = cur_date.timeIntervalSinceDate(last_active_date as NSDate)
        if interval > 5 {
            initialBillValue = 0.0
            
        }
        else {
            initialBillValue = defaults.floatForKey("stored_bill_amount")
        }
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}



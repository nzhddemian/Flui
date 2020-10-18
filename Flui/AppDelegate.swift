//
//  AppDelegate.swift
//  Flui
//
//  Created by Demian on 11.08.2020.
//  Copyright © 2020 Demian. All rights reserved.
//
import AudioKit
import UIKit
var active = false
//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    var window: UIWindow?

        
        //////ORientation
       // var orientationLock = UIInterfaceOrientationMask.all
        
       // func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
      //      return self.orientationLock
      //  }
        //////////////////  /
        
        

        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
            
            let viewController = ViewController(nibName: nil, bundle: nil) //ViewController = Name of your controller
            let navigationController = UINavigationController(rootViewController: viewController)
            window = UIWindow(frame: UIScreen.main.bounds)
            navigationController.isNavigationBarHidden = true
            window?.rootViewController = navigationController
            print("fghyuyhhjhjhjllllllllllljjjj")
            //window?.rootViewController?.view.addSubview(imageView)
            window?.makeKeyAndVisible()
            // Override point for customization after application launch.
            return true
        }

        func applicationWillResignActive(_ application: UIApplication) {
            
//            do{
//            try! AudioKit.start()
//            }

            
            active = false
            // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
            // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        }

        func applicationDidEnterBackground(_ application: UIApplication) {
            
//            do{
//            try! AudioKit.stop()
//            }

            
            ViewController.shared.metalView.isPaused = true
            print("BECOME BACKGROUND")
            // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
            // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        }

        func applicationWillEnterForeground(_ application: UIApplication) {
           // ViewController.shared.metalView.isPaused  = false
            // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
          //  active = false
        }

        func applicationDidBecomeActive(_ application: UIApplication) {
            
            ViewController.shared.metalView.isPaused  = false
         // active = false
            // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        }

        func applicationWillTerminate(_ application: UIApplication) {
            // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
            // Saves changes in the application's managed object context before the application terminates.
            //self.saveContext()
        }

       
        
    }


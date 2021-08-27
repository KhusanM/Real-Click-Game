//
//  AppDelegate.swift
//  Real_Click_Game
//
//  Created by Kh's MacBook on 25.08.2021.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        
        FirebaseApp.configure()
        
        let vc = EntryVC(nibName: "EntryVC", bundle: nil)
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .dark
        } else {
            // Fallback on earlier versions
        }
        
        return true
    }

    

}


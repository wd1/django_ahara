//
//  AppDelegate.swift
//  Ahara
//
//  Created by Miroslav Kostic on 4/7/21.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var hasAlreadyLaunched :Bool!
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        hasAlreadyLaunched = UserDefaults.standard.bool(forKey: "hasAlreadyLaunched")
        if hasAlreadyLaunched{
            hasAlreadyLaunched = true
            //here
            print(UserDefaults.standard.string(forKey: "auth_token"))
            if UserDefaults.standard.string(forKey: "auth_token") == nil{
                let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = dst_vc
                self.window?.makeKeyAndVisible()
            }else{
                let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyBoxViewController") as? MyBoxViewController
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = dst_vc
                self.window?.makeKeyAndVisible()
            }
        }else{
            UserDefaults.standard.set(true, forKey: "hasAlreadyLaunched")
            
            let dst_vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TutorialScreenViewController1") as? TutorialScreenViewController1
            self.window = UIWindow(frame: UIScreen.main.bounds)
            self.window?.rootViewController = dst_vc
            self.window?.makeKeyAndVisible()
        }
        
        return true
    }
}


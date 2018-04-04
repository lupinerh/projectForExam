//
//  CustomTabBarController.swift
//  project
//
//  Created by Stanislav Korolev on 25.02.18.
//  Copyright © 2018 Stanislav Korolev. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class CustomTabBarController: UITabBarController {
    
    var hello: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                print("пользователь")

                // User is signed in.
                self.setupCustomTabBar()
            } else {
                // No user is signed in.
                self.present(SignInController(), animated: false, completion: nil)
            }
        }
        

        
        
    }
    
    private func setupCustomTabBar(){
        
        let layout = UICollectionViewFlowLayout()
        
        // setup our custom view controllers
        let newsController = NewsController(collectionViewLayout: layout)
        let newsNavController = UINavigationController(rootViewController: newsController)
        newsNavController.tabBarController?.tabBar.barTintColor = .white
        newsNavController.tabBarItem.badgeColor = .black
        newsNavController.tabBarItem.title = "Новости"
        
        let layout1 = UICollectionViewFlowLayout()
        let scheduleController = ScheduleController(collectionViewLayout: layout1)
        let scheduleNavController = UINavigationController(rootViewController: scheduleController)
        scheduleNavController.tabBarController?.tabBar.barTintColor = .white
        scheduleNavController.tabBarItem.badgeColor = .black
        scheduleNavController.tabBarItem.title = "Расписание"
        
        let dialogsController = DialogsController(collectionViewLayout: layout)
        let dialogsNavController = UINavigationController(rootViewController: dialogsController)
        dialogsNavController.tabBarController?.tabBar.barTintColor = .white
        dialogsNavController.tabBarItem.badgeColor = .black
        dialogsNavController.tabBarItem.title = "Сообщения"
        
        // setup our custom view controllers
        let settingsController = SettingsController()
        let settingsNavController = UINavigationController(rootViewController: settingsController)
        settingsNavController.tabBarController?.tabBar.barTintColor = .white
        settingsNavController.tabBarItem.badgeColor = .black
        settingsNavController.tabBarItem.title = "Настройки"
        
        
        
        viewControllers = [scheduleNavController, newsNavController, dialogsNavController, settingsNavController]
    }
    
}

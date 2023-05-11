//
//  AppDelegate.swift
//  ZBBasicUtilsDemo
//
//  Created by biyuhuaping on 05/10/2023.
//  Copyright (c) 2023 biyuhuaping. All rights reserved.
//

import UIKit
import ZBBasicUtilsDemo
import BaiduMapAPI_Map
import BaiduMapAPI_Search

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        XYYLocationManager.start(with: "RKuRzPikLuTINnEM9uRpihvaAxMoSdmO");
        BMKMapManager().start("RKuRzPikLuTINnEM9uRpihvaAxMoSdmO", generalDelegate: nil)
        return true
    }
}


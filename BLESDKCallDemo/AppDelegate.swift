//
//  AppDelegate.swift
//  BLESDKCallDemo
//
//  Created by Spectra-iOS on 19/03/25.
//

import UIKit
import CoreLocation
import SpectraBLEiOS

@main
class AppDelegate: UIResponder, UIApplicationDelegate {


    var window: UIWindow?
   // var locationManager = CLLocationManager()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        SpectraBLE.shared.locationManager.requestAlwaysAuthorization()
        
        return true
    }


}


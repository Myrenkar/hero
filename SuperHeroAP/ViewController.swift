//
//  ViewController.swift
//  SuperHeroAP
//
//  Created by Piotr Torczyski on 25/05/16.
//  Copyright © 2016 SoInteractive. All rights reserved.
//

import UIKit
import QuartzCore
import CoreLocation



class ViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var topImage: UIImageView!
    @IBOutlet weak var bottomImage: UIImageView!
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    
    
    var beaconRegion: CLBeaconRegion!
    
    var locationManager: CLLocationManager!
    
    var isSearchingForBeacons = false
    
    var lastFoundBeacon: CLBeacon! = CLBeacon()
    
    var lastProximity: CLProximity! = CLProximity.Unknown
    
    let firstBeacon = BeaconModel()
    let secondBeacon = BeaconModel()
    let thirdBeacon =  BeaconModel()
    let fourthBeacon = BeaconModel()
    
    var isFirstImageShown = false
    var isSecondImageShown = false
    var isThirdImageShown = false
    var isFourthImageShown = false
    
    var uuidsArray = [String]()
    override func viewDidLoad() {
        
        self.backgroundImage.hidden = true
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        
        
        firstBeacon.major = 1000
        firstBeacon.minor = 597
        firstBeacon.uuid = "cdac6577-ea6c-4db6-8c08-918ef0c1756a"
        
        
        secondBeacon.major = 1000
        secondBeacon.minor = 624
        secondBeacon.uuid = "cdac6577-ea6c-4db6-8c08-918ef0c1756a"
        
        
        thirdBeacon.major = 46339
        thirdBeacon.minor = 56811
        thirdBeacon.uuid = "4d100990-0f3e-444f-8184-a840bbd1aa8c"
        
        
        fourthBeacon.major = 1000
        fourthBeacon.minor = 2977
        fourthBeacon.uuid = "4d100990-0f3e-444f-8184-a840bbd1aa8c"
        
        uuidsArray.append(firstBeacon.uuid!)
        uuidsArray.append(fourthBeacon.uuid!)
      
        setupBeaconWithUIID(uuidsArray)
        prepareImages()
    }
    
    
    func setupBeaconWithUIID(uuid : [String]){
        
        for proximityUUID in uuid{
            
            
            let newId =  NSUUID(UUIDString:proximityUUID)
            
            beaconRegion = CLBeaconRegion(proximityUUID: newId!, identifier: "com.sointeractive.SuperHeroAP \(proximityUUID)")
            
            beaconRegion.notifyOnEntry = true
            beaconRegion.notifyOnExit = true
            locationManager.requestAlwaysAuthorization()
            locationManager.startMonitoringForRegion(beaconRegion)
            locationManager.startUpdatingLocation()
            
        }
        
    }
    
    func prepareImages(){
        
        self.topImage.hidden =  true
        self.bottomImage.hidden =  true
        self.leftImage.hidden =  true
        self.rightImage.hidden =  true
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        locationManager.requestStateForRegion(region)
    }
    
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        if state == CLRegionState.Inside {
            locationManager.startRangingBeaconsInRegion(beaconRegion)
        }
        else {
            locationManager.stopRangingBeaconsInRegion(beaconRegion)
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        debugPrint("Beacon in range")
        
    }
    
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        debugPrint("No beacons in range")
    }
    
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        //        var shouldHideBeaconDetails = true
        
        if  !beacons.isEmpty {
            if beacons.count > 0 {
                if let closestBeacon = beacons[0] as? CLBeacon {
                    if closestBeacon != lastFoundBeacon || lastProximity != closestBeacon.proximity  {
                        lastFoundBeacon = closestBeacon
                        lastProximity = closestBeacon.proximity
                        
                        var proximityMessage: String!
                        switch lastFoundBeacon.proximity {
                        case CLProximity.Immediate:
                            proximityMessage = "Very close"
                            
                            if closestBeacon.minor == firstBeacon.minor{
                                self.topImage.hidden =  false
                                isFirstImageShown = true
                            } else if  closestBeacon.minor == secondBeacon.minor {
                                
                                self.rightImage.hidden = false
                                isSecondImageShown = true
                            } else if  closestBeacon.minor == thirdBeacon.minor {
                                
                                self.bottomImage.hidden = false
                                isThirdImageShown = true
                            } else if closestBeacon.minor == fourthBeacon.minor {
                                
                                self.leftImage.hidden = false
                                isFourthImageShown = true
                            }
                            
                            
                        case CLProximity.Near:
                            proximityMessage = "Near"
                            
                        case CLProximity.Far:
                            proximityMessage = "Far"
                            
                        default:
                            proximityMessage = "Where's the beacon?"
                        }
                        
                        //                        shouldHideBeaconDetails = false
                        
                        debugPrint("Beacon Details:\nMajor =  \(String(closestBeacon.major.intValue))  \nMinor = \(String(closestBeacon.minor.intValue))  \nDistance:  \(proximityMessage)  \(closestBeacon.proximityUUID.UUIDString)")
                    }
                }
            }
        }
        
    }
    
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error)
    }
    
    
    func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
        print(error)
    }
    
    
    func locationManager(manager: CLLocationManager, rangingBeaconsDidFailForRegion region: CLBeaconRegion, withError error: NSError) {
        print(error)
    }
    
    
}


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
import AVFoundation


class ViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var wiedzaLabel: UILabel!
    @IBOutlet weak var silaLabel: UILabel!
    @IBOutlet weak var pomyslyLabel: UILabel!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var topImage: UIImageView!
    
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    
    var player: AVAudioPlayer?
    
    var beaconRegion: CLBeaconRegion!
    
    var locationManager: CLLocationManager!
    
    var isSearchingForBeacons = false
    
    var lastFoundBeacon: CLBeacon! = CLBeacon()
    
    var lastProximity: CLProximity! = CLProximity.Unknown
    
    let firstBeacon = BeaconModel()
    let secondBeacon = BeaconModel()
    let thirdBeacon =  BeaconModel()
    
    
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
        
        
        thirdBeacon.major = 1000
        thirdBeacon.minor = 2977
        thirdBeacon.uuid = "4d100990-0f3e-444f-8184-a840bbd1aa8c"
        
        uuidsArray.append(firstBeacon.uuid!)
        uuidsArray.append(thirdBeacon.uuid!)
        
        setupBeaconWithUIID(uuidsArray)
        prepareImages()
    }
    
    func stopBeacons(uuid: [String]){
        
        for proximityUUID in uuid{
            
            
            let newId =  NSUUID(UUIDString:proximityUUID)
            
            beaconRegion = CLBeaconRegion(proximityUUID: newId!, identifier: "com.sointeractive.SuperHeroAP \(proximityUUID)")
            
            beaconRegion.notifyOnEntry = true
            beaconRegion.notifyOnExit = true
            locationManager.stopMonitoringForRegion(beaconRegion)
            locationManager.stopRangingBeaconsInRegion(beaconRegion)
        }
        
        
    }
    
    func setupBeaconWithUIID(uuid : [String]){
        
        for proximityUUID in uuid{
            
            
            let newId =  NSUUID(UUIDString:proximityUUID)
            
            beaconRegion = CLBeaconRegion(proximityUUID: newId!, identifier: "com.sointeractive.SuperHeroAP \(proximityUUID)")
            
            beaconRegion.notifyOnEntry = true
            beaconRegion.notifyOnExit = true
            locationManager.startMonitoringForRegion(beaconRegion)
            locationManager.startRangingBeaconsInRegion(beaconRegion)
        }
        
    }
    
    func prepareImages(){
        
        self.topImage.hidden =  true
        self.leftImage.hidden =  true
        self.rightImage.hidden =  true
        self.backgroundImage.hidden = true
        self.wiedzaLabel.text = "Szukaj dalej!"
        self.pomyslyLabel.text = "Szukaj dalej!"
        self.silaLabel.text = "Szukaj dalej!"
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
        
        if  !beacons.isEmpty {
            if beacons.count > 0 {
                if let closestBeacon = beacons[0] as? CLBeacon {
                    if closestBeacon != lastFoundBeacon || lastProximity != closestBeacon.proximity  {
                        lastFoundBeacon = closestBeacon
                        lastProximity = closestBeacon.proximity
                        
                        
                        
                        var proximityMessage: String!
                        switch lastFoundBeacon.proximity {
                        case CLProximity.Immediate:
                            
                            proximityMessage = "Bardzo blisko"
                            
                            
                            if closestBeacon.minor == firstBeacon.minor{
                                self.topImage.hidden =  false
                                isFirstImageShown = true
                                silaLabel.hidden = true
                                
                            } else if  closestBeacon.minor == secondBeacon.minor {
                                
                                self.rightImage.hidden = false
                                isSecondImageShown = true
                                pomyslyLabel.hidden = true
                                
                            } else if closestBeacon.minor == thirdBeacon.minor {
                                isFourthImageShown = true
                                self.leftImage.hidden = false
                                
                                wiedzaLabel.hidden = true
                            }
                            
                            setupLabels(closestBeacon, message: proximityMessage)
                            
                            
                        case CLProximity.Near:
                            
                            proximityMessage = "Blisko"
                            
                            setupLabels(closestBeacon, message: proximityMessage)
                        case CLProximity.Far:
                            
                            proximityMessage = "Daleko"
                            
                            setupLabels(closestBeacon, message: proximityMessage)
                        default:
                            proximityMessage = "Szukaj dalej!"
                            
                            setupLabels(closestBeacon, message: proximityMessage)
                        }
                        
                        if isFirstImageShown && isSecondImageShown && isFourthImageShown {
                            stopBeacons(uuidsArray)
                            playSound()
                            
                            let actionSheetController: UIAlertController = UIAlertController(title: "Hurra!", message: "Jesteś superbohaterem!", preferredStyle: .Alert)
                            
                            //Create and add the Cancel action
                            let cancelAction: UIAlertAction = UIAlertAction(title: "OK", style: .Cancel) { action -> Void in
                                self.isFirstImageShown = false
                                self.isSecondImageShown = false
                                self.isFourthImageShown = false
                                self.backgroundImage.hidden = false
                                self.topImage.hidden = true
                                self.leftImage.hidden = true
                                self.rightImage.hidden = true
                                
                            }
                            actionSheetController.addAction(cancelAction)
                            self.presentViewController(actionSheetController, animated: true, completion: nil)
                        }
                        
                        
                        debugPrint("Beacon Details:\nMajor =  \(String(closestBeacon.major.intValue))  \nMinor = \(String(closestBeacon.minor.intValue))  \nDistance:  \(proximityMessage)")
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
    
    @IBAction func resetState(sender: AnyObject) {
        
        setupBeaconWithUIID(uuidsArray)
        prepareImages()
        isFirstImageShown = false
        isSecondImageShown = false
        isFourthImageShown = false
        self.wiedzaLabel.text = "Szukaj dalej!"
        self.pomyslyLabel.text = "Szukaj dalej!"
        self.silaLabel.text = "Szukaj dalej!"
        
        self.wiedzaLabel.hidden = false
        self.pomyslyLabel.hidden = false
        self.silaLabel.hidden = false
        
        player?.stop()
        
    }
    func playSound() {
        let url = NSBundle.mainBundle().URLForResource("dzwonek", withExtension: "mp3")!
        
        do {
            player = try AVAudioPlayer(contentsOfURL: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
            debugPrint("played")
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func setupLabels(beacon: CLBeacon, message : String){
        
        
        if beacon.minor == firstBeacon.minor{
            silaLabel.text = message
            
        } else if  beacon.minor == secondBeacon.minor {
            
            pomyslyLabel.text = message
            
        } else if beacon.minor == thirdBeacon.minor {
            wiedzaLabel.text = message
        }
        
        
    }
    
}


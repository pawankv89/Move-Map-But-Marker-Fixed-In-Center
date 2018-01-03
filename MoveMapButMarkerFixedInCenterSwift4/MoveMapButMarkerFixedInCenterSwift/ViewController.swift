//
//  ViewController.swift
//  MoveMapButMarkerFixedInCenterSwift
//
//  Created by Pawan kumar on 12/21/17.
//  Copyright © 2017 Pawan Kumar. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController,UIGestureRecognizerDelegate,MKMapViewDelegate,CLLocationManagerDelegate {
    
    var mapChangedFromUserInteraction: Bool = false
    var mapChangedFirstTime: Bool = false
    
    @IBOutlet weak var mapView : MKMapView!
    var locationManager : CLLocationManager!
    @IBOutlet weak var addressLabel : UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Show Address on MAP View
        self.addressLabel.text = "Loading..."
        
        self.mapView.delegate = self;
        self.mapView.showsUserLocation = true;
        
        updateCurrentLocationOfUser()
        
        viewDidLoadGesture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func viewDidLoadGesture() ->Void {
        
       let panGesture:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.didDragMap(_:)))
        panGesture.delegate = self
        mapView?.isUserInteractionEnabled = true
        mapView?.addGestureRecognizer(panGesture)
        
    }
    
    @objc func didDragMap(_ gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == .ended {
            print("drag ended")
            
            let coordinate : CLLocationCoordinate2D  = self.mapView.centerCoordinate;
            
            //Add Annotation on MapView
            addAnnotationOnMapView(coordinate: coordinate)
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        /*if (gestureRecognizer is UIPanGestureRecognizer || gestureRecognizer is UIRotationGestureRecognizer) {
            return true
        } else {
            return false
        }*/
        
        return true
    }
    
    private func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = self.mapView.subviews[0]
        //  Look through gesture recognizers to determine whether this region change is from user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if( recognizer.state == UIGestureRecognizerState.began || recognizer.state == UIGestureRecognizerState.ended ) {
                    return true
                }
            }
        }
        return false
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation){
        
        if (!mapChangedFirstTime) {
            
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
            self.mapView.setRegion(region, animated: true)
            
            addAnnotationOnMapView(coordinate: userLocation.coordinate)
        }
    }

    
   func updateCurrentLocationOfUser(){
    
    self.locationManager = CLLocationManager.init()
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    
    if #available(iOS 8, *) {
        // iOS 8 (or newer) Swift code
        self.locationManager.requestAlwaysAuthorization()
    } else {
        // iOS 8 or older code
        self.locationManager.startUpdatingLocation()
    }
  }
    
    func removeOldAnnotationOnMapView(){
    
    if self.mapView.annotations.count>0 {
        self.mapView.removeAnnotations(self.mapView.annotations)
        }
      }
    
    func addAnnotationOnMapView(coordinate:CLLocationCoordinate2D){
        
        //Remove Old Annotation on Map View
        removeOldAnnotationOnMapView()
        
        mapChangedFirstTime = true;
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Pawan Kumar"
        annotation.subtitle = "I'm in Delhi Pitampura!!!"
        self.mapView.addAnnotation(annotation)
    
        reverseGeocodeLocation(coordinate: coordinate)
    }
    
    // reverseGeocodeLocation
    func reverseGeocodeLocation(coordinate:CLLocationCoordinate2D) {
       
        var placemark: CLPlacemark!
        let location: CLLocation = CLLocation.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error)->Void in
            if error == nil {
                
                if placemarks!.count > 0{
                    
                    placemark = placemarks![0]
                    let addressDictionary: NSDictionary = placemark.addressDictionary! as NSDictionary
                    
                    print("AddressDictionary is \(addressDictionary)")
                
                    var address: String = ""
                    var city: String = ""
                    var state: String = ""
                    var zIPCode: String = ""
                    
                    if (addressDictionary.object(forKey: "Name") != nil) {
                        address = addressDictionary.object(forKey: "Name") as! String
                    }
                    if (addressDictionary.object(forKey: "City") != nil) {
                        city = addressDictionary.object(forKey: "City") as! String
                    }
                    if (addressDictionary.object(forKey: "State") != nil) {
                        state = addressDictionary.object(forKey: "State") as! String
                    }
                    if (addressDictionary.object(forKey: "ZIP") != nil) {
                        zIPCode = addressDictionary.object(forKey: "ZIP") as! String
                    }
                    
                    //Address
                    let addressRecived = "\(address) \(city) \(state) \(zIPCode)"
                    self.addressLabel.text = addressRecived
                }
            }
        })
    }
}



MoveMapButMarkerFixedInCenter
=========

## MoveMapButMarkerFixedInCenter.
------------
 Added Some screens here.
 
[![](https://github.com/pawankv89/MoveMapButMarkerFixedInCenter/blob/master/Screens/1.png)]

## Usage
------------
 iOS 9 Demo showing how to droodown on iPhone X Simulator in  Objective-C and Swift 4.0.


```objective-c
#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLGeocoder.h>
#import <Contacts/Contacts.h>

static BOOL mapChangedFromUserInteraction = NO;
static BOOL mapChangedFirstTime = NO;

@interface ViewController ()<MKMapViewDelegate,UIGestureRecognizerDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UILabel *addressLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
[super viewDidLoad];
// Do any additional setup after loading the view, typically from a nib.

//Show Address on MAP View
self.addressLabel.text = @"Loading...";

self.mapView.delegate = self;
self.mapView.showsUserLocation = true;

//Update User Current Location
[self updateCurrentLocationOfUser];

//Update Marker Pin on MapView
[self viewDidLoadMoveMapView];
}

- (void)didReceiveMemoryWarning {
[super didReceiveMemoryWarning];
// Dispose of any resources that can be recreated.
}

#pragma MArk - Start Drag MapView
-(void)viewDidLoadMoveMapView {

UIPanGestureRecognizer* panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
[panRec setDelegate:self];
[self.mapView addGestureRecognizer:panRec];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
return YES;
}

- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer {
if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
NSLog(@"drag ended");

CLLocationCoordinate2D coordinate = [self.mapView centerCoordinate];

//Add Annotation on MapView
[self addAnnotationOnMapView:coordinate];
}
}

- (BOOL)mapViewRegionDidChangeFromUserInteraction
{
UIView *view = self.mapView.subviews.firstObject;
//  Look through gesture recognizers to determine whether this region change is from user interaction
for(UIGestureRecognizer *recognizer in view.gestureRecognizers) {
if(recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateEnded) {
return YES;
}
}

return NO;
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
mapChangedFromUserInteraction = [self mapViewRegionDidChangeFromUserInteraction];

if (mapChangedFromUserInteraction) {
// user changed map region
NSLog(@"regionWillChangeAnimated");
}
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
if (mapChangedFromUserInteraction) {
// user changed map region
NSLog(@"regionDidChangeAnimated");
}
}
#pragma MArk - End Drag MapView

-(void)updateCurrentLocationOfUser{

_locationManager = [[CLLocationManager alloc] init];
_locationManager.delegate = self;
_locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
[_locationManager requestAlwaysAuthorization];
}
[_locationManager startUpdatingLocation];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
if (!mapChangedFirstTime) {

//Zoom on Map Annotation
MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 800, 800);
[self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];

//Add Annotation on MapView
[self addAnnotationOnMapView:userLocation.coordinate];
}
}

-(void)removeOldAnnotationOnMapView{

if (self.mapView.annotations) {
if ([self.mapView.annotations count]>0) {
[self.mapView removeAnnotations:[self.mapView annotations]];
}
}
}

-(void)addAnnotationOnMapView:(CLLocationCoordinate2D)coordinate{

//Remove Old Annotation on Map View
[self removeOldAnnotationOnMapView];

mapChangedFirstTime = YES;

// Add an annotation
MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
point.coordinate = coordinate;
point.title = @"Pawan Kumar";
point.subtitle = @"I'm in Delhi Pitampura!!!";

[self.mapView addAnnotation:point];

[self reverseGeocodeLocation:coordinate];
}

-(void)reverseGeocodeLocation:(CLLocationCoordinate2D)coordinate{

CLGeocoder *geocoder = [[CLGeocoder alloc] init];

CLLocation *newLocation = [[CLLocation alloc]initWithLatitude:coordinate.latitude
longitude:coordinate.longitude];

[geocoder reverseGeocodeLocation:newLocation
completionHandler:^(NSArray *placemarks, NSError *error) {

if (error) {
NSLog(@"Geocode failed with error: %@", error);
return;
}

if (placemarks && placemarks.count > 0)
{
CLPlacemark *placemark = placemarks[0];

NSDictionary *addressDictionary = placemark.addressDictionary;

NSLog(@"%@ ", addressDictionary);
NSString *address = [addressDictionary
objectForKey:@"Name"];
NSString *city = [addressDictionary
objectForKey:@"City"];
NSString *state = [addressDictionary
objectForKey:@"State"];
NSString *zip = [addressDictionary
objectForKey:@"ZIP"];

if ([address length] == 0) {
address = @"";
}
if ([city length] == 0) {
city = @"";
}
if ([state length] == 0) {
state = @"";
}
if ([zip length] == 0) {
zip = @"";
}

self.addressLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@", address,city, state, zip];
}
}];
}


```

```Swift


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

```

## License

This code is distributed under the terms and conditions of the [MIT license](LICENSE).

## Change-log

A brief summary of each this release can be found in the [CHANGELOG](CHANGELOG.mdown). 

//
//  ViewController.m
//  MoveMapButMarkerFixedInCenter
//
//  Created by Pawan kumar on 12/20/17.
//  Copyright © 2017 Pawan Kumar. All rights reserved.
//

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


@end

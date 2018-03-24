//
//  KCUserLocation.h
//  StravaDemo
//
//  Created by owen on 16/6/6.
//  Copyright © 2016年 owen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface KCUserLocation : NSObject<MKAnnotation>

@property (nonatomic, getter=isUpdating) BOOL updating;

// Returns nil if the owning MKMapView's showsUserLocation is NO or the user's location has yet to be determined.
@property (nonatomic, nullable) CLLocation *location;

// Returns nil if not in MKUserTrackingModeFollowWithHeading
@property (nonatomic, nullable) CLHeading *heading ;

// The title to be displayed for the user location annotation.
@property (nonatomic, copy, nullable) NSString *title;

// The subtitle to be displayed for the user location annotation.
@property (nonatomic, copy, nullable) NSString *subtitle;



@property (nonatomic) CLLocationCoordinate2D coordinate;


@end

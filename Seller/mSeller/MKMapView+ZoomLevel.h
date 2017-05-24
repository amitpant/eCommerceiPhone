//
//  MKMapView+ZoomLevel.h
//  mSeller
//
//  Created by Rajesh Pandey on 11/13/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MKMapView (ZoomLevel)
- (void)setCenterCoordinate:(CLLocationCoordinate2D)centerCoordinate
                  zoomLevel:(NSUInteger)zoomLevel
                   animated:(BOOL)animated;

@end

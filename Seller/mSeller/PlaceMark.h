//
//  PlaceMark.h
//  mSeller
//
//  Created by Rajesh Pandey on 11/13/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface PlaceMark : NSObject<MKAnnotation>
{
CLLocationCoordinate2D coordinate;
}
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString* T_Title;
@property (nonatomic, strong) NSString* T_SubtTitle;
@property (nonatomic, strong) NSManagedObject* customerInfo;
@property(nonatomic,assign) NSInteger selectedBtnTag;
-(id)initWithCoordinate:(CLLocationCoordinate2D) c;
-(id)initWithCoordinate:(CLLocationCoordinate2D) c Title:(NSString *)titleval  Subtitle:(NSString *)subtitleval;
-(id)initWithCoordinate:(CLLocationCoordinate2D) c Title:(NSString *)titleval  Subtitle:(NSString *)subtitleval ManagedObject:(NSManagedObject *)customerInfo Selectedbtn:(NSInteger)selectedbtn;
- (NSString *)subtitle;
- (NSString *)title;

@end

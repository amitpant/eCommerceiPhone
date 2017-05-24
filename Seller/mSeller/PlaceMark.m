//
//  PlaceMark.m
//  mSeller
//
//  Created by Rajesh Pandey on 11/13/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "PlaceMark.h"

@implementation PlaceMark
@synthesize coordinate;
- (NSString *)subtitle{
    return _T_SubtTitle;
}
- (NSString *)title{
    return _T_Title;
}
-(id)initWithCoordinate:(CLLocationCoordinate2D) c{
    coordinate=c;
    self.T_Title = @"Parked Location";
    self.T_SubtTitle = @"put some text here";
    return self;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c Title:(NSString *)titleval  Subtitle:(NSString *)subtitleval{
    coordinate=c;
    self.T_Title = titleval;
    self.T_SubtTitle = subtitleval;
    return self;
}

-(id)initWithCoordinate:(CLLocationCoordinate2D) c Title:(NSString *)titleval  Subtitle:(NSString *)subtitleval ManagedObject:(NSManagedObject *)customerInfo Selectedbtn:(NSInteger)selectedbtn
{
    coordinate=c;
    if([titleval length]>0 && ![[customerInfo valueForKey:@"delivery_address"] isEqualToString:@"000"]){
        self.T_Title = [NSString stringWithFormat:@"%@-DELVADD",titleval];
    }
    else
        self.T_Title = titleval;
    self.T_SubtTitle = subtitleval;
    _customerInfo = customerInfo;
    _selectedBtnTag=selectedbtn;
    return self;
}

@end

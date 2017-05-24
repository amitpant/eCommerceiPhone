//
//  TranFotterBreakDown.h
//  mSeller
//
//  Created by Mahendra Pratap Singh on 9/27/16.
//  Copyright © 2016 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TranFotterBreakDown : UIViewController

@property(nonatomic,strong) NSString* strTotal;
@property(nonatomic,strong) NSString* strNow;
@property(nonatomic,strong) NSString* strFuture;
@property(nonatomic,strong) NSString* orderNumber;
@property(nonatomic,strong) NSString* txtsearch;
@property (nonatomic,unsafe_unretained) BOOL isEditing;

@property (nonatomic,strong) NSManagedObject *Headrecorddata;
@end

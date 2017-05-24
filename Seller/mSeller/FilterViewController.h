//
//  FilterViewController.h
//  mSeller
//
//  Created by Rajesh Pandey on 9/14/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FilterViewControllerDelegate <NSObject>
@optional
-(void)finishedTransactionFilterSelectionWithOption:(NSDictionary*)selDictionary;
-(void)finishedTransactionFilterSelectionWithSingleOption:(NSDictionary*)retDict;
@end

@interface FilterViewController : UIViewController
{
}

@property(readwrite,nonatomic) NSInteger filterStatus;

- (IBAction)changeSegmentValue:(id)sender;

@property(strong,nonatomic) NSMutableDictionary *returnDictionary;
@property(strong,nonatomic) NSString *retval;
@property(assign,nonatomic) BOOL callLogStatus;
@property(weak,nonatomic) id<FilterViewControllerDelegate> delegate;
@end

//
//  DatePickerViewController.h
//  mSeller
//
//  Created by Rajesh Pandey on 12/23/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatePickerTableViewCell.h"
@protocol DatePickerViewControllerDelegate <NSObject>
@optional
-(void)finishedSelectionWithDate:(NSDate *)seldate;
-(void)finishedSelectionWithFromDate:(NSDate *)fromdate ToDate:(NSDate *)todate;
@end

@interface DatePickerViewController : UIViewController
@property(weak,nonatomic) id<DatePickerViewControllerDelegate> delegate;
@property(nonatomic,assign)BOOL isDateRange;
@property(nonatomic,strong)NSDate *selectedDate;
@property(nonatomic,strong)NSDate *selectedToDate;

@property(nonatomic,assign)BOOL clearSelectionEnabled;
@property(nonatomic,assign)BOOL isCallBack;
@end

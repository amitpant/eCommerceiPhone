//
//  CustomerDateViewController.h
//  mSeller
//
//  Created by Ashish Pant on 9/15/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#define Width_View 320
#define Height_View 480
#define Static_Y_Space 5   //80
#define Width_calendarView 144  //280
#define Height_calendarView 144  //244
#define Minus_month_for_Previous_Action 24  //from 8 as shown 12 months
#define Seconds_of_Minute 60
#define Minutes_of_Hour 60
#define Hours_of_Day 24
#define Origin_of_calendarView 78
#define Width_Allocated_for_CalendarViews 290

@protocol CustomDatePickerControllerDelegate <NSObject>
-(void)finishedSelectionWithDone:(NSDate *)seldate;
@end
@interface CustomDatePickerViewController : UIViewController<EKEventEditViewDelegate>
{
    BOOL isLeft;
    NSDate *dtForMonth;
    int originX,originY;
}
//-(void)createCalendar;
-(IBAction)next;
-(IBAction)previous;
@property(strong,nonatomic) NSDate *selectedDate;
@property(weak,nonatomic) id<CustomDatePickerControllerDelegate> delegate;
@property(nonatomic,weak)IBOutlet UIScrollView *scrollView;
@property (nonatomic,strong) IBOutlet UIView *vwCalendar;
@property (nonatomic,strong) IBOutlet UIButton *btnPrevious;
@property (nonatomic,strong) IBOutlet UIButton *btnNext;
@property (nonatomic,strong) IBOutlet UILabel *lblMonth;
@property (nonatomic,strong) IBOutlet UILabel *lblYearShow;

// Default calendar associated with the above event store
@property (nonatomic, strong) EKCalendar *defaultCalendar;

// Array of all events happening within the next 24 hours
@property (nonatomic, strong) NSMutableArray *eventsList;
@property(nonatomic,assign) BOOL runloop;
@property (nonatomic,strong)NSMutableArray *arrDate;
@end

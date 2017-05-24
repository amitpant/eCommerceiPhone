//
//  CalendarCollectionViewCell.m
//  mSeller
//
//  Created by Satish Kr Singh on 08/12/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "CalendarCollectionViewCell.h"
@interface CalendarCollectionViewCell(){
    NSArray *arrWeekdays;
}
//@property (nonatomic,strong) NSMutableArray * DateLabels;
@property (nonatomic,unsafe_unretained) NSInteger reduceDayCount; // to get actual date

@end

@implementation CalendarCollectionViewCell

-(void)awakeFromNib{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    arrWeekdays = [dateFormatter veryShortWeekdaySymbols];

    // create month header
    UILabel *lblMonthCaption = [[UILabel alloc] initWithFrame:CGRectMake(5, 2, 80, 17)];
    lblMonthCaption.font = [UIFont systemFontOfSize:14.0];
    lblMonthCaption.tag = 111;
    lblMonthCaption.minimumScaleFactor = 0.5;
    [self.contentView addSubview:lblMonthCaption];

    // create header label
    CGFloat topPos = 21;
    CGFloat leftPos = 1;

    CGFloat controlwidth = 21;
    NSInteger dayTagCounter = 101;
    for (NSString *dayname in arrWeekdays) {
        UILabel *lblDayCaption = [[UILabel alloc] initWithFrame:CGRectMake(leftPos, topPos, controlwidth, controlwidth)];
        lblDayCaption.font = [UIFont boldSystemFontOfSize:12.0];
        lblDayCaption.textAlignment = NSTextAlignmentCenter;
        lblDayCaption.text = dayname;
        lblDayCaption.tag = dayTagCounter;
        lblDayCaption.minimumScaleFactor = 0.5;
        [self.contentView addSubview:lblDayCaption];
        leftPos+=controlwidth+1;
        dayTagCounter++;
    }
    topPos+=controlwidth+2;

    dayTagCounter = 1;
    for(int i = 1;i<= 5;i++){
        leftPos = 1;
        for (NSString *dayname in arrWeekdays) {
            UIButton *btnDayVal = [UIButton buttonWithType:UIButtonTypeCustom];
            btnDayVal.frame = CGRectMake(leftPos, topPos, controlwidth, controlwidth);
            btnDayVal.titleLabel.font = [UIFont systemFontOfSize:12.0];
            [btnDayVal setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            btnDayVal.titleLabel.textAlignment = NSTextAlignmentCenter;
            //[btnDayVal setTitle:dayname forState:UIControlStateNormal];
            //[btnDayVal setBackgroundImage:[UIImage p] forState:<#(UIControlState)#>]
            btnDayVal.tag = dayTagCounter;
            btnDayVal.titleLabel.minimumScaleFactor = 0.5;
            [btnDayVal addTarget:self action:@selector(doSelectDate:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:btnDayVal];

//            [_DateBtns addObject:btnDayVal];

            leftPos+=controlwidth+1;
            dayTagCounter++;

            DebugLog(@"%@",dayname);
        }
        topPos+=controlwidth+2;
    }
}

-(void)setValueForMonth:(NSInteger)monthval Year:(NSInteger)yearval{
    _monthValue = monthval;
    _yearValue = yearval;

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];

    // Set your year and month here
    [components setYear:yearval];
    [components setMonth:monthval];

    NSDate *date = [calendar dateFromComponents:components];
    NSInteger dayCount = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;

    [components setDay:1];
    NSDate *firstdate = [calendar dateFromComponents:components];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEEE"];

    NSDateFormatter *dateFormatter1 = [[NSDateFormatter alloc] init];
    NSArray *weekdayFull = [dateFormatter1 weekdaySymbols];

    _reduceDayCount = [weekdayFull indexOfObject:[dateFormatter stringFromDate:firstdate]];

    [dateFormatter setDateFormat:@"MMM"];
    UILabel *lblMonthName = [self.contentView viewWithTag:111];
    lblMonthName.text = [[dateFormatter stringFromDate:firstdate] uppercaseString];
    [lblMonthName sizeToFit];

    CGFloat topPos = lblMonthName.frame.size.height+4;
    CGFloat leftPos = 1;
    CGFloat controlwidth = (self.frame.size.width - 7)/7;

    // set frame for the day labels
    NSInteger dayTagCounter = 100;
    for(int i = 1;i<= 7;i++){
        UILabel *lblDayCaption = [self.contentView viewWithTag:100+i];
        lblDayCaption.frame = CGRectMake(leftPos, topPos, controlwidth, controlwidth);
        leftPos+=controlwidth+1;
    }
    topPos+=controlwidth+2;

    // set frame & values for days
    dayTagCounter = 1;
    NSInteger dayVal = 1;
    for(int i = 1;i<= 5;i++){
        leftPos = 1;
        for (NSString *dayname in arrWeekdays) {
            DebugLog(@"%@",dayname);
            UIButton *btnDayVal = [self.contentView viewWithTag:dayTagCounter];
            if(_reduceDayCount+1>dayTagCounter || dayVal > dayCount){
                [btnDayVal setTitle:nil forState:UIControlStateNormal];
                btnDayVal.enabled = NO;
                leftPos+=controlwidth+1;
                dayTagCounter++;
                continue;
            }

            btnDayVal.frame = CGRectMake(leftPos, topPos, controlwidth, controlwidth);
            [btnDayVal setTitle:[NSString stringWithFormat:@"%li",dayVal] forState:UIControlStateNormal];

            dayTagCounter++;
            dayVal++;
            leftPos+=controlwidth+1;
        }
        topPos+=controlwidth+2;
    }
}

-(void)doSelectDate:(UIButton *)sender{
    if([self.delegate respondsToSelector:@selector(getSelectedCustomDate:)]){
        NSDateComponents *components = [[NSDateComponents alloc] init];

        // Set your year and month here
        [components setDay:sender.tag - (_reduceDayCount-1)];
        [components setMonth:_monthValue];
        [components setYear:_yearValue];
        [components setHour:0];
        [components setMinute:0];
        [components setSecond:0];

        NSCalendar *calendar = [NSCalendar currentCalendar];
        [self.delegate getSelectedCustomDate:[calendar dateFromComponents:components]];
    }
}


@end

//
//  CalendarCollectionViewCell.h
//  mSeller
//
//  Created by Satish Kr Singh on 08/12/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CalendarCollectionViewCellDelegate <NSObject>
-(void)getSelectedCustomDate:(NSDate *)date;

@end

@interface CalendarCollectionViewCell : UICollectionViewCell

@property(nonatomic,unsafe_unretained)NSInteger monthValue;
@property(nonatomic,unsafe_unretained)NSInteger yearValue;
@property(nonatomic,weak)id delegate;

-(void)setValueForMonth:(NSInteger)monthval Year:(NSInteger)yearval;

@end

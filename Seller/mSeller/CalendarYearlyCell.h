//
//  CalendarYearlyCell.h
//  mSeller
//
//  Created by Satish Kr Singh on 10/12/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CalendarYearlyCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblYear;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end

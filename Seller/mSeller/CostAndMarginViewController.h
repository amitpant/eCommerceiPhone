//
//  CostAndMarginViewController.h
//  mSeller
//
//  Created by Rajesh Pandey on 4/22/16.
//  Copyright © 2016 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CostAndMarginTableViewCell.h"

@interface CostAndMarginViewController : UIViewController
{
}
@property (weak, nonatomic) IBOutlet UITableView *tableCostAndMargins;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (nonatomic,strong) NSArray* arrRecords;
@property (nonatomic,strong) NSString *strCurr;

@end

//
//  ProductHistoryTableViewCell.h
//  mSeller
//
//  Created by Ashish Pant on 10/21/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductHistoryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *productCode;
@property (weak, nonatomic) IBOutlet UILabel *productDescription;
@property (weak, nonatomic) IBOutlet UILabel *freeCaption;
@property (weak, nonatomic) IBOutlet UILabel *freeValue;
@property (weak, nonatomic) IBOutlet UILabel *qtyCaption;
@property (weak, nonatomic) IBOutlet UILabel *qtyValue;
@property (weak, nonatomic) IBOutlet UILabel *priceCaption;
@property (weak, nonatomic) IBOutlet UILabel *priceValue;
@property (weak, nonatomic) IBOutlet UILabel *lastCaption;
@property (weak, nonatomic) IBOutlet UILabel *lastValue;
@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIButton *btnCheck;

@property (unsafe_unretained, nonatomic) BOOL isInvoiced;

@end

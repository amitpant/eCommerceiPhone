//
//  ProductHistoryInvoicesOutstandingTableViewCell.h
//  mSeller
//
//  Created by Ashish Pant on 11/6/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductHistoryInvoicesOutstandingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *productCode;
@property (weak, nonatomic) IBOutlet UILabel *productDescription;
@property (weak, nonatomic) IBOutlet UILabel *quantityCaption;
@property (weak, nonatomic) IBOutlet UILabel *quantityValue;
@property (weak, nonatomic) IBOutlet UILabel *priceCaption;
@property (weak, nonatomic) IBOutlet UILabel *priceValue;
@property (weak, nonatomic) IBOutlet UILabel *valueCaption;
@property (weak, nonatomic) IBOutlet UILabel *valueTotal;

@end

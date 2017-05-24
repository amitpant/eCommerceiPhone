//
//  CustomerDetailInvoiceOutstandingTableViewCell.h
//  mSeller
//
//  Created by Rajesh Pandey on 11/9/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerDetailInvoiceOutstandingTableViewCell : UITableViewCell
{
}
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UILabel *productCode;
@property (weak, nonatomic) IBOutlet UILabel *productDescription;
@property (weak, nonatomic) IBOutlet UILabel *productQuantityCaption;
@property (weak, nonatomic) IBOutlet UILabel *productQuantity;
@property (weak, nonatomic) IBOutlet UILabel *productPriceCaption;
@property (weak, nonatomic) IBOutlet UILabel *productPrice;
@property (weak, nonatomic) IBOutlet UILabel *productValueCaption;
@property (weak, nonatomic) IBOutlet UILabel *productValue;
@property(unsafe_unretained,nonatomic)BOOL isInvoiced;
@property (unsafe_unretained,nonatomic)BOOL isColorChangeRequired;
@property (weak, nonatomic) IBOutlet UIButton *btnCheck;
@end

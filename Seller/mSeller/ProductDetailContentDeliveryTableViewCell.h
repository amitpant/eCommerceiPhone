//
//  ProductDetailContentDeliveryTableViewCell.h
//  mSeller
//
//  Created by Ashish Pant on 10/27/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductDetailContentDeliveryTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *delIdValue;
@property (weak, nonatomic) IBOutlet UILabel *townValue;
@property (weak, nonatomic) IBOutlet UIButton *btnDate;
@property (weak, nonatomic) IBOutlet UIButton *btnQuantity;

@end

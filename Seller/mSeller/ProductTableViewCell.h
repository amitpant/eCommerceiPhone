//
//  ProductTableViewCell.h
//  mSeller
//
//  Created by Rajesh Pandey on 9/22/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProductTVCellDelegate <NSObject>
@optional
-(IBAction)btnQuantityClicked:(UIButton*)sender Cell:(UITableViewCell*)cell;
-(void)btnQuantity_longPress:(UIButton*)btnsender  Cell:(UITableViewCell*)cell;
-(void)btnQuantity_longPressEnd:(UIButton*)btnsender  Cell:(UITableViewCell*)cell;

@end

@interface ProductTableViewCell : UITableViewCell<UIGestureRecognizerDelegate>
{
    NSInteger lastTag;
   // int icounter;
    NSDictionary* priceConfigDict;
}
@property(weak,nonatomic)IBOutlet UIImageView *imgViewProduct;
@property(weak,nonatomic)IBOutlet UILabel *lblProductCode;
@property(weak,nonatomic)IBOutlet UILabel *lblProductName;

@property(weak,nonatomic)IBOutlet UIView *viewPriceCaptionAndValue;

@property (weak, nonatomic) IBOutlet UIButton *btnNext;
@property (weak, nonatomic) IBOutlet UIView *viewPrice;
@property (weak, nonatomic) IBOutlet UIView *viewPacks;


@property (nonatomic,strong) NSArray* arrpacks;
@property (nonatomic) double orderPrice;
//Fields OutletCollection

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *PackLabels;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *PackBtns;
@property (weak, nonatomic) IBOutlet UIView *viewPackBtns;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewPackBtnLayoutWidthConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *packBtnWidthLayoutConstraint;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *packLblWidthLayoutConstraint;


//Price OutletCollection
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *priceFiledLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *priceLabels;

@property (nonatomic)id<ProductTVCellDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *groupColorImgView;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *lblfilters;


@end

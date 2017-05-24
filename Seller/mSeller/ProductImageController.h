//
//  ProductImageController.h
//  mSeller
//
//  Created by Satish Kr Singh on 27/11/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProductImageControllerDelegate <NSObject>

@optional
-(void)showFullScreenOnImageZoom;

@end
@interface ProductImageController : UIViewController

@property NSUInteger pageIndex;
@property(strong,nonatomic)id productDetail;
@property (weak,nonatomic) id<ProductImageControllerDelegate> delegate;
- (void) setImageName: (NSString *) strfinalimage;

@end

//
//  productImageIteams.h
//  mSeller
//
//  Created by WCT iMac on 06/11/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProductDetailBaseController.h"

@interface productImageIteams : ProductDetailBaseController<UIScrollViewDelegate>


@property (nonatomic) NSUInteger itemIndex;
@property (nonatomic, strong) NSString *imageName;
// IBOutlets
@property (nonatomic, weak) IBOutlet UIImageView *contentImageView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView; 
@property (weak, nonatomic) IBOutlet UILabel *lblShortDesc;
@property (weak, nonatomic) IBOutlet UITextView *txtLongDesc;
@property (nonatomic, strong) NSManagedObject *record;
- (void) setImageName: (NSString *) name;
@end

//
//  CustomerInfoController.h
//  mSeller
//
//  Created by Ashish Pant on 9/15/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomerInfoTableViewCell.h"
#import "BaseContentViewController.h"
@interface CustomerInfoController : BaseContentViewController<UITableViewDelegate,UITableViewDataSource>{
    
}

@property(nonatomic,weak)NSString *ProductCode;
@end

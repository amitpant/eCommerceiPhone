//
//  BaseContentViewController.h
//  mSeller
//
//  Created by Rajesh Pandey on 10/20/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BaseContentViewControllerDelegate <NSObject>
@optional
-(void)loadSegment;
@end


@interface BaseContentViewController : UIViewController
{
}

@property(nonatomic,strong)NSManagedObject *customerInfo;
@property(nonatomic,weak)NSManagedObject *transactionInfo;
-(void)loadScrollEnable;
-(void)loadLeft;
@property(weak,nonatomic) id<BaseContentViewControllerDelegate> delegate;
@end

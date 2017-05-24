//
//  CustomerNewDeliveryAddressViewController.h
//  mSeller
//
//  Created by Ashish Pant on 11/16/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseContentViewController.h"

@protocol CustomerNewDeliveryAddressDelegate <NSObject>

@optional
-(void)finishNewDeliverySaveDone;
-(void)finishedDeliverySaveDone:(NSMutableArray*)selAcc_Ref;
@end


@interface CustomerNewDeliveryAddressViewController : BaseContentViewController<UITextFieldDelegate>{
    
    //id<CustomerNewDeliveryAddressDelegate>delegate;
}
@property(nonatomic,weak)id<CustomerNewDeliveryAddressDelegate>delegate;
@property(nonatomic,assign) BOOL editStatus;
@property(nonatomic,strong) NSManagedObject *customerDelivery;

- (IBAction)cancelButtonClick:(id)sender;
- (IBAction)saveButtonClick:(id)sender;

@end

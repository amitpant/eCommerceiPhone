//
//  CrreateTransactionDelegate.h
//  mSeller
//
//  Created by Satish Kr Singh on 18/12/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CreateTransactionDelegate <NSObject>
@optional
-(void)createTransactionWithCustomerInfo:(NSManagedObject *)custinfo;
@end

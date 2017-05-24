//
//  NSString+TruncateToWidth.h
//  mSeller
//
//  Created by Satish Kumar on 12/24/12.
//  Copyright (c) 2012 Williams Commerce Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString(TruncateToWidth)
- (NSString*)stringByTruncatingToWidth:(CGFloat)width withFont:(UIFont *)font;
@end

//
//  ProductTableViewCell.m
//  mSeller
//
//  Created by Rajesh Pandey on 9/22/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "ProductTableViewCell.h"
#import "Constants.h"

@implementation ProductTableViewCell

- (void)awakeFromNib {
    // Initialization code
    lastTag=-1;
    
    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:PricingConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        priceConfigDict = [dic objectForKey:@"data"];
    
    
    for (UIButton *packButton in _PackBtns) {
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]   initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.5; //seconds
    longPress.delegate = self;
    [packButton addGestureRecognizer:longPress];
 }
    
    _viewPrice.layer.cornerRadius = 5.0;
    _viewPrice.layer.borderColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0].CGColor;
    _viewPrice.layer.borderWidth=1.0;
    
    _viewPackBtns.layer.cornerRadius = 5.0;
    _viewPackBtns.layer.borderColor = SelectedBackgroundColor.CGColor;
    _viewPackBtns.layer.borderWidth=1.0;
    
    if ([kUserDefaults  integerForKey:@"PriceDisplay"]==2) {
        [_viewPrice setHidden:NO];
    }else
        [_viewPrice setHidden:YES];
    
        
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(IBAction)btnQuantityClicked:(UIButton*)sender
{
    _arrpacks = [[priceConfigDict objectForKey:@"orderpanellabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.includeinsidebar==1"]];
    NSArray* arrDefault = [[priceConfigDict objectForKey:@"orderpanellabels"] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.includeinsidebar==1 && self.defaultdenomination==1"]];
    int defaultIndex=[_arrpacks indexOfObject:[arrDefault  firstObject]];
   
   
  //Click functionality
    if ([sender tag]==defaultIndex && (lastTag==-1 ) ) {// Added for  || lastTag==0  after scroll double qty added
        UIButton *totbtn=[[_PackBtns filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",[_arrpacks count]]]lastObject];
        if (![totbtn.backgroundColor  isEqual: btnBlueColor]) {
            [totbtn setTitle:[NSString stringWithFormat:@"0"] forState:UIControlStateNormal];
        }
      lastTag=[sender tag];
    }else  if ([sender tag]!=lastTag) {
        
        UIButton *totbtn=[[_PackBtns filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.tag==%li",[_arrpacks count]]]lastObject];
        if (![totbtn.backgroundColor  isEqual: btnBlueColor]) {
        [totbtn setTitle:[NSString stringWithFormat:@"0"] forState:UIControlStateNormal];
        }
        lastTag=[sender tag];
    }
    
    [self.delegate btnQuantityClicked:sender Cell:self];
}

-(void) handleLongPress : (UILongPressGestureRecognizer *)gestureRecognizer
{
    UIButton *myButton = (id)gestureRecognizer.view;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {

        [self.delegate btnQuantity_longPress:myButton  Cell:self];
    }else
    {
        if (gestureRecognizer.state == UIGestureRecognizerStateCancelled
            || gestureRecognizer.state == UIGestureRecognizerStateFailed
            || gestureRecognizer.state == UIGestureRecognizerStateEnded)
        {
            // Long press ended, stop the timer
            [self.delegate btnQuantity_longPressEnd:myButton Cell:self];
        }
    }
    
    DebugLog(@"handleLongPress");
    //Long Press done by the user
}

@end

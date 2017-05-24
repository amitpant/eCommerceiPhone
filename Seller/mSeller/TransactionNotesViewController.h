//
//  TransactionNotesViewController.h
//  mSeller
//
//  Created by Rajesh Pandey on 9/21/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NotesViewControllerDelegate <NSObject>

@optional
-(void)finishedNoteSelectionWithOption:(NSDictionary*)selDictionary;
@end

@interface TransactionNotesViewController : UIViewController
{   
    //SignatureView *signatureView;
}


@property(strong,nonatomic) NSDictionary* returnDictionary;
@property(strong,nonatomic) NSString* noteType;
@property(weak,nonatomic) id<NotesViewControllerDelegate> delegate;


- (IBAction)done_click:(id)sender;
@end

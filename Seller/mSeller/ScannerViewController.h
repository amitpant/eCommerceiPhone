//
//  ScannerViewController.h
//  mSeller
//
//  Created by Ashish Pant on 12/14/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//
@protocol ScannerViewControllerDelgate <NSObject>

-(void)getScannedBarCodes:(NSMutableArray*)scannedArray;

@end
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface ScannerViewController : UIViewController<AVCaptureMetadataOutputObjectsDelegate>
@property (weak, nonatomic) IBOutlet UIView *viewPreview;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UIButton *bbitemStart;
@property (weak, nonatomic) NSString *scanningType;
@property (strong, nonatomic) NSMutableArray *scanningTypeArray;

@property(nonatomic,weak)id <ScannerViewControllerDelgate>delegate;
- (IBAction)startStopReading:(id)sender;
@end

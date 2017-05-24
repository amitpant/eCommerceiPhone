//
//  SignatureViewController.m
//  mSeller
//
//  Created by WCT iMac on 25/11/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "SignatureViewController.h"
#import "SignView.h"

@interface SignatureViewController ()

@end

@implementation SignatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
 
    [self performSelector:@selector(load_Signature) withObject:nil afterDelay:0.1];
    
    NSString *imagePath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingPathComponent:[NSString stringWithFormat:@"%li/SignatureFolder/%@.png",(long)kAppDelegate.selectedCompanyId,_ordnumber]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        [_signImgView setHidden:NO];
        [_signImgView setImage:[UIImage imageWithContentsOfFile:imagePath]];
    }
    
}

-(void)load_Signature{
 //   _signatureView.layer.masksToBounds=YES;
 //   _signatureView.layer.cornerRadius=6.0;
    signView=nil;
    signView=[[SignView alloc]initWithFrame:_signatureView.bounds];
    [_signatureView addSubview:signView];
    _signatureView.backgroundColor=[UIColor greenColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_signImgView setHidden:YES];
}


-(IBAction)clearView:(id)sender
{
    for (UIView *vieww  in _signatureView.subviews){
        if (vieww)
            [vieww removeFromSuperview];
    }
    signView=nil;
    signView=[[SignView alloc]initWithFrame:_signatureView.bounds];
    [_signatureView addSubview:signView];
    
    [_signImgView setHidden:YES];
    
}
-(IBAction)saveSign:(id)sender
{
    
    UIGraphicsBeginImageContextWithOptions(signView.bounds.size,YES, 0.0);
    [_signatureView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    NSString *imagePath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingPathComponent:[NSString stringWithFormat:@"%li/SignatureFolder",(long)kAppDelegate.selectedCompanyId]];
    
   // NSString *imagePath=[NSString stringWithFormat:@"%%@/ImgFolder",[[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld",(long)kAppDelegate.selectedCompanyId]]];
    if(![[NSFileManager defaultManager] fileExistsAtPath:imagePath])
    {
        NSError* error;
        [[NSFileManager defaultManager] createDirectoryAtPath:imagePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }
    imagePath=[imagePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.png",_ordnumber]];
    [UIImagePNGRepresentation(img) writeToFile:imagePath atomically:YES];
    UIGraphicsEndImageContext();
    //transobject.forSavesignature = YES;
    //[self.popOver.delegate popoverControllerDidDismissPopover:self.popOver];
    
    [self.navigationController popViewControllerAnimated:YES];
}



@end

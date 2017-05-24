//
//  ProductImageController.m
//  mSeller
//
//  Created by Satish Kr Singh on 27/11/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "ProductImageController.h"

@interface ProductImageController (){
    NSMutableArray *moreImageArray;
    NSString *stractualpath;
    NSDictionary* companyConfigDict;//   fetch CompanyConfig
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ProductImageController


#pragma mark - Custom Methods
-(void)reloadConfigData{
    NSDictionary *dic=[CommonHelper loadFileDataWithVirtualFilePath:FeaturesConfigFileName];
    //  Mahendra fetch CompanyConfig
    companyConfigDict = nil;
    dic=[CommonHelper loadFileDataWithVirtualFilePath:CompanyConfigFileName];
    if(dic && ![[dic objectForKey:@"data"] isEqual:[NSNull null]])
        companyConfigDict = [dic objectForKey:@"data"];
    dic=nil;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self reloadConfigData];
    
    stractualpath = [[[kAppDelegate applicationDocumentsDirectory] path] stringByAppendingFormat:@"/%li/images",(long)kAppDelegate.selectedCompanyId];

   /* NSString *strfinalimage = [[stractualpath stringByAppendingPathComponent:[[CommonHelper getStringByRemovingSpecialChars:[_productDetail valueForKey:@"stock_code"]] lowercaseString]] stringByAppendingString:@".jpg"];
    [_imageView setImageWithURL:strfinalimage?[NSURL fileURLWithPath:strfinalimage]:nil placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    */
    
    NSString* tstr = [NSString stringWithFormat:@"%@~",[[CommonHelper getStringByRemovingSpecialChars:[_productDetail valueForKey:@"stock_code"]] lowercaseString]];
    NSPredicate *fltr = [NSPredicate predicateWithFormat:@"self BEGINSWITH %@",tstr];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirContents = [fm contentsOfDirectoryAtPath:stractualpath error:nil];
    NSArray *moreArr=[dirContents filteredArrayUsingPredicate:fltr];
    
    if ([moreArr count]>1) {
        NSString* tstr1 = [NSString stringWithFormat:@"%@",[[CommonHelper getStringByRemovingSpecialChars:[_productDetail valueForKey:@"stock_code"]] lowercaseString]];
        fltr = [NSPredicate predicateWithFormat:@"self BEGINSWITH %@ || self BEGINSWITH %@",tstr1,tstr];
        moreImageArray=[NSMutableArray arrayWithArray:[dirContents filteredArrayUsingPredicate:fltr]];
        
        NSString *strfinalimage = [stractualpath stringByAppendingPathComponent:[[CommonHelper getStringByRemovingSpecialChars:[moreImageArray objectAtIndex:_pageIndex]] lowercaseString]];
        [_imageView setImageWithURL:strfinalimage?[NSURL fileURLWithPath:strfinalimage]:nil placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        
    }else{
        NSString *strfinalimage;
        
        if ([[[companyConfigDict valueForKey:@"tradename"] lowercaseString] hasPrefix:@"henbrandt"]) {
            strfinalimage = [[stractualpath stringByAppendingPathComponent:[[CommonHelper getStringByRemovingSpecialChars:[[_productDetail valueForKey:@"stock_code"] stringByReplacingOccurrencesOfString:@" " withString:@""]] lowercaseString]] stringByAppendingString:@".jpg"];
        }else
            strfinalimage = [[stractualpath stringByAppendingPathComponent:[[CommonHelper getStringByRemovingSpecialChars:[_productDetail valueForKey:@"stock_code"]] lowercaseString]] stringByAppendingString:@".jpg"];
        
        [_imageView setImageWithURL:strfinalimage?[NSURL fileURLWithPath:strfinalimage]:nil placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)doOpenFullScreen:(id)sender {
    if([(UIGestureRecognizer *)sender state]==UIGestureRecognizerStateRecognized){
        if([self.delegate respondsToSelector:@selector(showFullScreenOnImageZoom)]){
            [self.delegate showFullScreenOnImageZoom];
        }
    }
}


- (void) setImageName: (NSString *) strfinalimage{
    [_imageView setImageWithURL:strfinalimage?[NSURL fileURLWithPath:strfinalimage]:nil placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

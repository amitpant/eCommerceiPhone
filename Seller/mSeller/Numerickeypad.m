//
//  Numerickeypad.m
//  mSeller
//
//  Created by WCT iMac on 04/12/15.
//  Copyright © 2015 Williams Commerce Ltd. All rights reserved.
//

#import "Numerickeypad.h"

@interface Numerickeypad (){
    NSString *returnStr;
}

@end

@implementation Numerickeypad

/*
 0 Tag for 0
 1 Tag for 1
 0 Tag for 0
 0 Tag for 0
 0 Tag for 0
 8 Tag for 8
 9 Tag for 9
 10 Tag for .
 11 Tag for x
 12 Tag for cancel
 13 Tag for return
 
 */




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor=[UIColor clearColor];
//    self.modalPresentationStyle = UIModalPresentationCurrentContext;
//    self.modalPresentationStyle = UIModalPresentationFormSheet;
    
    returnStr=_txtnumberpad.text;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if([self.delegate respondsToSelector:@selector(cancelkeyClick)])
        [self.delegate cancelkeyClick];
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

- (IBAction)keyboard_click:(id)sender {
    
    NSString *value=[NSString stringWithFormat:@"%li",(long)[sender tag] ];
    
    if([returnStr isEqualToString:@"0"] && [returnStr length]==1 && [sender tag]!=10){
        returnStr=@"";
    }
        
    
    switch ([sender tag]) {
        case 0:
            returnStr=[returnStr stringByAppendingString:value];
            break;
       
        case 1:
            returnStr=[returnStr stringByAppendingString:value];
            break;
            
        case 2:
           returnStr=[returnStr stringByAppendingString:value];
            break;
            
        case 3:
            returnStr=[returnStr stringByAppendingString:value];
            break;
            
        case 4:
            returnStr=[returnStr stringByAppendingString:value];
            break;
            
        case 5:
            returnStr=[returnStr stringByAppendingString:value];
            break;
            
        case 6:
            returnStr=[returnStr stringByAppendingString:value];
            break;
            
        case 7:
            returnStr=[returnStr stringByAppendingString:value];
            break;
            
        case 8:
           returnStr= [returnStr stringByAppendingString:value];
            break;
            
        case 9:
            returnStr=[returnStr stringByAppendingString:value];
            break;
            
        case 10:{
            
            if ([returnStr rangeOfString:@"."].location == NSNotFound) {
                returnStr=[returnStr stringByAppendingString: [NSString stringWithFormat:@"."]];
            }
        }
            
            break;
            
        case 11:{
            if ([returnStr length]>0 ) {
                returnStr=[returnStr substringToIndex:[returnStr length] - 1];
             
            }
            if ([returnStr isEqualToString:@""]) {
                returnStr=@"0";
            }
            
        }break;
            
        case 12: {
            [self dismissViewControllerAnimated:NO completion:nil];
            
        }
        break;
            
        case 13:
            [self.delegate retuenkeyClickwithOption:returnStr Button:_clickBtn];
            [self dismissViewControllerAnimated:NO completion:nil];
            break;
            
        default:
            break;
    }
    
   
    _txtnumberpad.text=returnStr;
}
@end

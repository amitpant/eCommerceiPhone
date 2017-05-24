//
//  PasscodeViewController.m
//  mSeller
//
//  Created by Mahendra iMac on 15/09/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "PasscodeViewController.h"

@interface PasscodeViewController (){
    
    NSString *passcodeString;
}
@property(weak,nonatomic) IBOutlet UILabel *lblErrorMsg;
@property (weak, nonatomic) IBOutlet UILabel *lblText;
@property (weak, nonatomic) IBOutlet UITextField *txt1;
@property (weak, nonatomic) IBOutlet UITextField *txt2;
@property (weak, nonatomic) IBOutlet UITextField *txt3;
@property (weak, nonatomic) IBOutlet UITextField *txt4;

@property(nonatomic ,unsafe_unretained)BOOL checkpasscode;
@property (weak, nonatomic)NSString *strfull;
@property (nonatomic,assign)BOOL isValidation;

@end

@implementation PasscodeViewController
@synthesize txt1,txt2,txt3,txt4;
@synthesize strfull;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    txt1.tintColor = [UIColor clearColor];
    txt2.tintColor = [UIColor clearColor];
    txt3.tintColor = [UIColor clearColor];
    txt4.tintColor = [UIColor clearColor];

    self.automaticallyAdjustsScrollViewInsets = false;
    self.automaticallyAdjustsScrollViewInsets = false;

    [_lblErrorMsg.layer setMasksToBounds:YES];
    [_lblErrorMsg.layer setCornerRadius:8.0];
    
    [txt1 becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
//    [self dismissViewControllerAnimated:NO completion:nil];
}



-(void) next:(NSNumber *)tag;
{
  
    
    int txttag =(int) [tag integerValue];
    
    UITextField *txt=(UITextField*)[self.view viewWithTag:txttag];
    
    if(txt.text.length > 0)
    {
        txttag = txttag +1;
        
        UITextField *t;
        if(txttag > 3)
        {
            txttag = 0;
           // if([self insertPassCode])
            {
                t =(UITextField*)[self.view viewWithTag:txttag];
                [t becomeFirstResponder];
            }
            
        }
        else{
            t =(UITextField*)[self.view viewWithTag:txttag];
            [t becomeFirstResponder];
        }
        
        
    }
    
}


-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if(![textField.text isEqualToString:@"-"]){
        textField.secureTextEntry=YES;
        textField.font=[UIFont systemFontOfSize:25.0];
        
    }
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if([textField.text isEqualToString:@"-"]){
        textField.text=@"";
        textField.secureTextEntry=YES;
        textField.font=[UIFont systemFontOfSize:25.0];
    }

    if (range.location ==1 )
            {
                if(!_lblErrorMsg.hidden){
                    _lblErrorMsg.hidden=YES;
                }
                textField.text = nil;
                textField.text = string;
                
                if (textField == txt1) {
                    [txt2 becomeFirstResponder];
                }else  if (textField == txt2) {
                    [txt3 becomeFirstResponder];
                }else if (textField == txt3){
                    [txt4 becomeFirstResponder];
                }else if (textField == txt4){
                    [textField resignFirstResponder];
                    [self performSelector:@selector(insertOrValidatePassCode:) withObject:[NSString stringWithFormat:@"%@%@%@%@",txt1.text,txt2.text,txt3.text,txt4.text] afterDelay:0.25];
                }
                
                return NO;
            }



    return  YES;
}

-(void) cleartext
{
    self.txt1.text = @"-";
    self.txt2.text = @"-";
    self.txt3.text = @"-";
    self.txt4.text = @"-";
    self.txt1.secureTextEntry=NO;
    self.txt2.secureTextEntry=NO;
    self.txt3.secureTextEntry=NO;
    self.txt4.secureTextEntry=NO;

    self.txt1.font=[UIFont systemFontOfSize:45];
    self.txt2.font=self.txt1.font;
    self.txt3.font=self.txt1.font;
    self.txt4.font = self.txt1.font;
    [txt1 becomeFirstResponder];
}

-(void)insertOrValidatePassCode:(NSString *)passcode
{
    BOOL isExist = [kUserDefaults  objectForKey:@"settingpasscode"]!=nil && [[kUserDefaults  objectForKey:@"settingpasscode"] length]>0;

    if(!isExist){
        if(passcodeString==nil){
            passcodeString = passcode;
            [self cleartext];
            return;
        }
        else if(![passcodeString isEqualToString:passcode]){
            _lblErrorMsg.text = @"Invalid confirm passcode. please try again";
            _lblErrorMsg.hidden = NO;
            [self cleartext];
            return;
        }
        [kUserDefaults  setObject:passcode forKey:@"settingpasscode"];
        [kUserDefaults  synchronize];
    }
    else{
        if(![[kUserDefaults  objectForKey:@"settingpasscode"] isEqualToString:passcode]){
            _lblErrorMsg.text = @"Invalid passcode. please try again";
            _lblErrorMsg.hidden = NO;
            [self cleartext];
            return;
        }
    }
    [self performSegueWithIdentifier:@"toSettingsSegue" sender:self];
}


//******* Navigation buttons action
- (IBAction)cancel_Click:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
 }


@end

//
//  LoginViewController.m
//  mSeller
//
//  Created by Ashish Pant on 9/10/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()<SwitchCompanyDelagate>{
    BOOL isViewLoaded;
    BOOL isLoginTapped;
    BOOL isUserAlreadyLoggedIn;
}

@property(nonatomic,weak)IBOutlet UITextField *txtUserName;
@property(nonatomic,weak)IBOutlet UITextField *txtPassword;
@property(nonatomic,weak)IBOutlet UIButton *btnLogin;
@property(nonatomic,weak)IBOutlet UIScrollView *scrollMain;
@property(nonatomic,weak)IBOutlet UIView *viewMain;
@property(nonatomic,weak)IBOutlet UIView *viewUserName;
@property(nonatomic,weak)IBOutlet UIView *viewPassword;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

- (IBAction)doLogin :(id)sender;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    kAppDelegate.companyDelegate = self;
    
    [_viewUserName.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [_viewUserName.layer setBorderWidth:1.0];
    [_viewPassword.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [_viewPassword.layer setBorderWidth:1.0];
    
    isViewLoaded = YES;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    isUserAlreadyLoggedIn = NO;

    // to load username & password from user defaults if exist
    if(!_txtUserName.text || [_txtUserName.text length]==0)
        _txtUserName.text = [kUserDefaults  objectForKey:@"username"];
    
    if(!_txtPassword.text || [_txtPassword.text length]==0)
        _txtPassword.text = [kUserDefaults  objectForKey:@"password"];
    [_txtUserName becomeFirstResponder];
    
    if(isViewLoaded){
        isViewLoaded = NO;
        
        if(_txtUserName.text && [_txtUserName.text length]>0 && _txtPassword.text && [_txtPassword.text length]>0)
            [self performSelector:@selector(doLogin:) withObject:nil afterDelay:2.0];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SwitchCompanyDelagate
-(void)ConfigDownloadFinishedSuccessfully:(BOOL)issuccessful Error:(NSString *)error{
    if([kAppDelegate isAllConfigFileDownloaded]){
        if(!isUserAlreadyLoggedIn){
            [kAppDelegate saveDeviceUsesLogs];
            [self performSegueWithIdentifier:@"toHomeController" sender:self];
            isUserAlreadyLoggedIn = YES;
            
            [_activityIndicatorView stopAnimating];
        }
    }
    else{
        [kAppDelegate showCustomAlertWithModule:@"Login" Message:@"Unable to get all configuration from server."];
        isLoginTapped = NO;
    }
}

#pragma mark - UITextField Delegate
-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Custom Methods
- (IBAction)doLogin :(id)sender{
    if(isLoginTapped){
        isLoginTapped = NO;
        return;
    }
    
    if(!sender) isLoginTapped = NO;
    
    isLoginTapped = YES;
    
    //removing whitespaces and newline character from username textfield by Ashish
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedString = [self.txtUserName.text stringByTrimmingCharactersInSet:whitespace];
    self.txtUserName.text=trimmedString;
    //end of code added
    
    [self.txtUserName resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    
    if ([self.txtUserName.text length]==0 && [self.txtPassword.text length]==0) {
        [kAppDelegate showCustomAlertWithModule:@"Login" Message:@"Please enter username and password"];
        isLoginTapped = NO;
        return;
    }
    else if ([self.txtUserName.text length]==0){
        [kAppDelegate showCustomAlertWithModule:@"Login" Message:@"Please enter username"];
        isLoginTapped = NO;
        return;
    }
    else if ([self.txtPassword.text length]==0){
        [kAppDelegate showCustomAlertWithModule:@"Login" Message:@"Please enter password"];
        isLoginTapped = NO;
        return;
    }
    
    [_activityIndicatorView startAnimating];
    
    //end of code added by Ashish
    [self validateLogin];
}

-(void)validateLogin{
    
    
    
    NSDictionary *dic =  [CommonHelper loadFileDataWithVirtualFilePath:CompanyUsersFileName];
    
    //filter array by username  using predicate by Ashish
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username == %@ && password==%@",self.txtUserName.text,self.txtPassword.text];
    NSArray *filteredArray = [[[dic objectForKey:@"data"] objectForKey:@"users"] filteredArrayUsingPredicate:predicate];
    
    if ([filteredArray count]==0){
        [kAppDelegate showCustomAlertWithModule:@"Login" Message:@"Please enter valid username and password"];
        isLoginTapped = NO;
        return;
    }
    NSDictionary *dicdata=[filteredArray firstObject];
    kAppDelegate.repId = [dicdata objectForKey:@"repid"];
    kAppDelegate.loginUserId = [[dicdata objectForKey:@"userid"] integerValue];

    // to set user config directory
    NSString *strtempuserfile = [[[UserConfigFileName lastPathComponent] componentsSeparatedByString:@"_"] firstObject];
    NSString *strtempuserfileext = [UserConfigFileName pathExtension];
    UserConfigFileName = [NSString stringWithFormat:@"%li/%@_%@.%@",(long)kAppDelegate.selectedCompanyId,[strtempuserfile stringByDeletingPathExtension],kAppDelegate.repId,strtempuserfileext];
    
    [kUserDefaults  setObject:self.txtUserName.text forKey:@"username"];
    [kUserDefaults  setObject:self.txtPassword.text forKey:@"password"];
    
    [kUserDefaults  setObject:[NSNumber numberWithInteger:kAppDelegate.loginUserId] forKey:@"loginUserId"];
    [kUserDefaults  synchronize];
    
    // insert data only for the first time
    [kAppDelegate loadPrequisitesDataIntoSQLDB];

    if([kAppDelegate isAllConfigFileDownloaded]){
        isUserAlreadyLoggedIn = YES;
        [kAppDelegate reloadConfigurationData];

        [kAppDelegate saveDeviceUsesLogs];

        [self performSegueWithIdentifier:@"toHomeController" sender:self];
        [_activityIndicatorView stopAnimating];
    }
    else{
        [kAppDelegate reloadConfigurationData];
    }
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 @brief POST (* mandatory parameters)
 @param token *
 @param deviceudid *
 @param devicename
 @param devicetype
 @param devicemodel
 @param deviceosversion
 @param appversion
 @param companyid
 @param userid
 @param licenseid
 */

@end

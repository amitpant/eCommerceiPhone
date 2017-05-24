//
//  MailOptionsLayoutViewController.m
//  mSeller
//
//  Created by Rajesh Pandey on 9/15/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import "MailOptionsLayoutViewController.h"

@interface MailOptionsLayoutViewController (){
    
    NSArray*  optionArray;
}

@end

@implementation MailOptionsLayoutViewController
@synthesize optionStatus;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (optionStatus==0)
        optionArray=@[@"Layout Type",@"Sort By",@"With Values",@"Include T&C file"];
    else if (optionStatus==1)
        optionArray=@[@"Text",@"Small Photo",@"Large Photos",@"Offer Sheet",@"Csv File",@"Photo Excel"];
    else if (optionStatus==1)
        optionArray=@[@"Entered Sequence",@"Numeric",@"Alphabetic"];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"MailOptionLayoutCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    if (optionStatus==0) {
        if ([[[optionArray objectAtIndex:indexPath.row] lowercaseString] isEqualToString:@"with values"] || [[[optionArray objectAtIndex:indexPath.row] lowercaseString] isEqualToString:@"include t&c file"]) {
            cell.selectionStyle = NO;
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
            switchView.tag = indexPath.row;
            cell.accessoryView = switchView;
            [switchView addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.textLabel.text = [optionArray objectAtIndex:indexPath.row];
            return  cell;
        }else {
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = [optionArray objectAtIndex:indexPath.row];
            return  cell;
        }
        
    }else if (optionStatus==1 ||optionStatus==2) {
        cell.textLabel.text = [optionArray objectAtIndex:indexPath.row];
        return  cell;
    }else
        return 0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (optionStatus==0 && !([[[optionArray objectAtIndex:indexPath.row] lowercaseString] isEqualToString:@"with values"] || [[[optionArray objectAtIndex:indexPath.row] lowercaseString] isEqualToString:@"include t&c file"])) {
        
        
    }else if (optionStatus==1 || optionStatus==2){
        
        
    }
    
}


-(void) switchChanged:(UISwitch *)sender
{
   
    
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

@end

//
//  AppDelegate.h
//  mSeller
//
//  Created by Amit Pant on 9/9/15.
//  Copyright (c) 2015 Williams Commerce Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "SwitchCompanyDelagate.h"
#import <EventKitUI/EventKitUI.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,unsafe_unretained) NSInteger pageCount;
@property (unsafe_unretained,nonatomic) NSInteger loginUserId;
@property (strong,nonatomic) NSString *repId;

@property (unsafe_unretained,nonatomic) NSInteger selectedCompanyId;
@property (unsafe_unretained,nonatomic) NSInteger lastSelectedCompanyId;

@property (unsafe_unretained,nonatomic) NSInteger licenseId;
@property (strong,nonatomic) NSString *licenseType;

// to preserve customer & order information if customer selected/transaction initiated
@property (strong,nonatomic) NSManagedObject *customerInfo;
@property (strong,nonatomic) NSManagedObject *transactionInfo;

// Default Settings
@property (strong,nonatomic)NSMutableDictionary *dicCurrencies;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//@property (readonly,strong, nonatomic) AFHTTPSessionManager *sessionManager;
@property (readonly,strong, nonatomic) AFHTTPRequestOperationManager *requestManager;

@property (strong,nonatomic) id<SwitchCompanyDelagate> companyDelegate;

@property (unsafe_unretained,nonatomic) BOOL transactionTabClick;

@property(nonatomic,retain)EKEventStore *store;

@property (strong,nonatomic) NSMutableDictionary *colorPool;
@property (strong,nonatomic) NSMutableDictionary *colorPoolGroup;
@property (assign,nonatomic) BOOL isEditTransaction;
@property (assign,nonatomic) BOOL isEditTransactionItem;
@property (strong,nonatomic) NSManagedObject *editTransactionProd;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (NSString *)identifierForAdvertising;

-(void)showCustomAlertWithModule:(NSString *)module Message:(NSString *)message;

-(void)loadSelectedCompanyWithData:(NSDictionary *)dicCompany;
-(void)downloadCompanyUsersWithCompanyId:(NSString *)compid;
-(void)loadCompanyUsersWithData:(NSDictionary *)dic;
-(void)reloadConfigurationData;

// to insert default value supplied in the sqlite when user logged in
-(void)loadPrequisitesDataIntoSQLDB;
-(void)loadCustomerInfo;

-(BOOL)isAllConfigFileDownloaded;

-(void)saveDeviceUsesLogs;

@end


//
//  AppDelegate.m
//  GuysApp
//
//  Created by SARFO KANTANKA FRIMPONG on 5/6/18.
//  Copyright © 2018 SARFO KANTANKA FRIMPONG. All rights reserved.
//



#import "AppDelegate.h"
#import <Photos/Photos.h>
@interface AppDelegate ()

@end

@implementation AppDelegate
-(void)registerPushNotification{
    
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionAlert+UNAuthorizationOptionBadge+UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if(!granted){
            NSLog(@"%@ ",error);
        }
        else{
            [self getNotificaitionSettings];
            NSLog(@"Push Notification Request Granted");
        }
    }];
    
}
-(void)application:(UIApplication*)app didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken{
  m_deviceToken=[[NSString alloc]init];
 
    NSUInteger dataLength = deviceToken.length;
     if (dataLength == 0) {
       return;
     }

     const  char *dataBuffer = (const  char *)deviceToken.bytes;
     NSMutableString *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
     for (int i = 0; i < dataLength; ++i) {
       [hexString appendFormat:@"%02.2hhx", dataBuffer[i]];
     }
    m_deviceToken=[hexString copy];
    NSLog(@"Device Token : %@\t%@",m_deviceToken,[deviceToken description]);
    
    
    
    
    if(_appDelegate)
        [_appDelegate applicationDeviceToken:m_deviceToken];
    
    
}
-(void)getNotificaitionSettings{
    [[UNUserNotificationCenter currentNotificationCenter]setDelegate:self];
    [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if(settings.authorizationStatus==UNAuthorizationStatusAuthorized){
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication] registerForRemoteNotifications];
            });
        }else{
            
        }
    }];
    
    //get Message ID and compare to NewMsgTagView MsgId if the same then ignore showing NewMsgTagView
    m_notiDataDic=[[NSMutableArray<NSString*> alloc]init];
    dispatch_semaphore_t sema=dispatch_semaphore_create(4);
    [[UNUserNotificationCenter currentNotificationCenter] getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
        
        
        for (UNNotification* notification in notifications) {
            // do something with object
            NSString *msgID=[[[ [notification request] content] userInfo] objectForKey:@"msgID"];
            if(msgID)
                [self->m_notiDataDic addObject:msgID];
        }
        dispatch_semaphore_signal(sema);
    }];
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    [[UNUserNotificationCenter currentNotificationCenter] removeAllDeliveredNotifications];
   // [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}
-(void)application:(UIApplication*)app didFailToRegisterForRemoteNotificationsWithError:(nonnull NSError *)error{
    NSLog(@"Remote notification not available to the ff error :%@",error);
    //[self disableRemoteNotificationFeatures];
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(nonnull UNNotificationResponse *)response withCompletionHandler:(nonnull void (^)(void))completionHandler{
    NSLog(@"Notification Respond %@",[[[[response notification] request] content] userInfo]);
    if(_appDelegate)
        [_appDelegate userNotificationCenter:center didReceiveNotificationResponse:response withCompletionHandler:completionHandler];
    
    completionHandler();
}
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(nonnull UNNotification *)notification withCompletionHandler:(nonnull void (^)(UNNotificationPresentationOptions))completionHandler{
   //  NSLog(@"Notification Respond %@",notification  );
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if(_appDelegate)
       [_appDelegate application:application didFinishLaunchingWithOptions:launchOptions];
    //[[UIApplication sharedApplication]registerForRemoteNotifications];
   
   
    
    //photo

    return YES;
    
}


-(void)setDelegate:(id)dlgt{
    self->_appDelegate=dlgt;
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    if(_appDelegate)
       [_appDelegate applicationWillResignActive:application];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if(_appDelegate){
        NSLog(@"App is is on background with delegate");
        [_appDelegate applicationDidEnterBackground:application];
    }else{
        NSLog(@"App is is on background no delegate");
    }
       
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    NSLog(@"application Will EnterForeground");

     NSLog(@"App is on foreground");
    
  
    if(_appDelegate){
        [_appDelegate applicationWillEnterForeground:application];
        NSLog(@"App is on foreground");
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.


    if(_appDelegate)
       [_appDelegate applicationDidBecomeActive:application];
    NSLog(@"App is active now");
  
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    if(_appDelegate)
       [_appDelegate applicationWillTerminate:application];
     NSLog(@"App is inactive now");
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"GuysApp"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}


@end

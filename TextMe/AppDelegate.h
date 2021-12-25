//
//  AppDelegate.h
//  Guys!
//
//  Created by SARFO KANTANKA FRIMPONG on 5/6/18.
//  Copyright © 2018 SARFO KANTANKA FRIMPONG. All rights reserved.
//




#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import <CoreData/CoreData.h>



@protocol _AppDelegate <NSObject>
@optional
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationDidBecomeInActive:(UIApplication *)application;
- (void)applicationWillTerminate:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)applicationDeviceToken:(NSString*)tokeen;
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(nonnull UNNotificationResponse *)response withCompletionHandler:(nonnull void (^)(void))completionHandler;

@end
@interface AppDelegate : UIResponder <UIApplicationDelegate,UNUserNotificationCenterDelegate>{
@public
     void *m_xmppEngine;
    void *m_data;
        //date : from : to : msg : type
    //NSMutableArray *m_messagesDB;
    id<_AppDelegate> _appDelegate;
    //Contact list
    NSMutableArray *m_nameNNumber;
    NSString* m_deviceToken;
    NSString *m_toJid;
    UIViewController *m_viewControllar;
    UIViewController *m_chatControllar;
    UIViewController *m_contactViewController;
    NSMutableArray<NSString*> *m_notiDataDic;
    NSMutableArray *shareToArray;
    
    
}
@property (nonatomic,strong)NSMutableArray* _Nullable  xmppEgine;

@property (strong, nonatomic) UIWindow * _Nonnull window;


@property (readonly, strong) NSPersistentContainer *persistentContainer;
- (void)saveContext;
-(void)setDelegate:(id _Nullable )dlgt;


@end



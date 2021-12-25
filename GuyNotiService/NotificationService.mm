//
//  NotificationService.m
//  GuyNotiService
//
//  Created by SARFO KANTANKA FRIMPONG on 7/1/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import "NotificationService.h"
#import <ContactsUI/ContactsUI.h>

enum  MESSAGETYPE{TEXT=1,FILE_ASSET_ID=2,FILE_URL=3,YOUTUBE_LINK=4,REPLY=5,DELETE=6};
@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
   
    
   
    UNTextInputNotificationAction *reply=[UNTextInputNotificationAction actionWithIdentifier:@"REPLY" title:@"Reply" options:UNNotificationActionOptionNone textInputButtonTitle:@"Send" textInputPlaceholder:@"text..."];
    
    UNNotificationAction *view=[UNNotificationAction actionWithIdentifier:@"VIEW" title:@"View" options:UNNotificationActionOptionForeground];
    UNUserNotificationCenter *notiCenter=[UNUserNotificationCenter currentNotificationCenter];
    UNNotificationCategory  *category=[UNNotificationCategory categoryWithIdentifier:@"1" actions:@[reply,view] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
    
   
    [notiCenter setNotificationCategories:[NSSet setWithObjects:category, nil]];

    m_fromJID=[[request.content userInfo] valueForKey:@"jid"];
    MESSAGETYPE type=(MESSAGETYPE)((NSString*)[[[request.content userInfo] valueForKey:@"aps"] valueForKey:@"category"]).intValue;
    NSString *msgID=[[request.content userInfo] valueForKey:@"msgID"];
    NSString* msg=[[[[request.content userInfo] valueForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"];
    std::time_t ct = std::time(0);
     char* cc = ctime(&ct);
    [self setMessageID:msgID msdData:@{@"from":m_fromJID,@"to":[self getUserJID],@"msg":msg,@"msgType":[NSString stringWithFormat:@"%i",type],@"event":[NSNumber numberWithInteger:gloox::MessageEventDelivered],@"time":[NSString stringWithUTF8String:cc]}];
    NSDictionary* tmpInfo=[self groupContactFind:m_fromJID];
    NSString *name=[[NSString alloc]init];
    NSString*  number=[NSString stringWithUTF8String:gloox::JID(m_fromJID.UTF8String).username().c_str()];
    
    if([tmpInfo count]){
        name=[tmpInfo objectForKey:@"name"];
    }
  
    
    name=[name length]?name:number;
    
     
     self.bestAttemptContent = [request.content mutableCopy];

    switch (type) {
        case MESSAGETYPE::TEXT:{
           
          //  UNNotificationCategory
            self.bestAttemptContent.body=msg;
            self.bestAttemptContent.title = [@"MESSAGE From : " stringByAppendingString:name];
            //self.bestAttemptContent
             break;
        }
           
        case MESSAGETYPE::FILE_ASSET_ID:
            
            break;
        case MESSAGETYPE::REPLY:
              //self.bestAttemptContent.title = [@"Reply From : " stringByAppendingString:name];
            break;
        case MESSAGETYPE::DELETE:
            
            break;
        case MESSAGETYPE::FILE_URL:{
           
            
            
            NSString *fileExtension=[msg pathExtension];
        
             NSLog(@"msg----  %@\n",fileExtension);
            
           
            if([fileExtension isEqualToString:@"jpg"] ||[fileExtension isEqualToString:@"jpeg"] || [fileExtension isEqualToString:@"png"] || [fileExtension isEqualToString:@"tif"]){
               
                self.bestAttemptContent.body=@"";
                self.bestAttemptContent.title = [@"Image From : " stringByAppendingString:name];

            }else  if([fileExtension isEqualToString:@"mp4"] || [fileExtension isEqualToString:@"mp3"] || [fileExtension isEqualToString:@"MOV"]||[fileExtension isEqualToString:@"m4a"]){
                self.bestAttemptContent.body=@"";
                self.bestAttemptContent.title = [@"Video From : " stringByAppendingString:name];
            }else if([fileExtension isEqualToString:@"caf"]){
                self.bestAttemptContent.body=@"";
                self.bestAttemptContent.title =[ @"Voice Audio From : " stringByAppendingString:name];
            }
             break;
        }
            
           
        default:
            break;
    }
    //[notiCenter getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
    //     [self.bestAttemptContent setBadge:[NSNumber numberWithLong:[notifications count]]];
        //use this function to remove rest of msg from user replied;
      //   NSLog(@"Badge %lu",(unsigned long)[notifications count]);
    //}];
    
 

    self.contentHandler = contentHandler;
    self.contentHandler(self.bestAttemptContent);
    
  
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

-(NSDictionary*)groupContactFind:(NSString*)partJID{
    NSString *appGroupDirectoryPath =[[[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.guys"]  URLByAppendingPathComponent:@"ContactInfo.txt"] path];
    NSDictionary*tmpDic=[NSDictionary dictionaryWithContentsOfFile:appGroupDirectoryPath];
    
    if(![tmpDic objectForKey:partJID]){
        return @{};
    }
    return @{@"name":[tmpDic objectForKey:partJID],@"jid":partJID};
}

-(void)setMessageID:(NSString*)_id msdData:(NSDictionary*) msg{
    NSString *appGroupDirectoryPath = [[[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.guys"].path   stringByAppendingPathComponent:@"Messages"] stringByAppendingPathExtension:@"txt"];
    NSError *error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:appGroupDirectoryPath])
        [[NSFileManager defaultManager] createFileAtPath:appGroupDirectoryPath contents:nil attributes:@{NSFileAppendOnly:@"NO",NSFileImmutable:@"NO"}]; //Create folder
    if(error){
        NSLog(@" Fail to Create Message File Error : %@",error);
        return;
    }
    //if([@"Hello" writeToFile:appGroupDirectoryPath atomically:YES encoding:NSUTF8StringEncoding error:&error])
    NSMutableDictionary *msgD=[NSMutableDictionary dictionaryWithContentsOfFile:appGroupDirectoryPath];
    if(!msgD)
        msgD=[[NSMutableDictionary alloc]init];
    [msgD setObject:msg forKey:_id];
    if([msgD writeToFile:appGroupDirectoryPath atomically:YES])
        NSLog(@"AG: Message Saved");
     // NSLog(@"%@",msgD);
    
    
    
}
-(NSString*) getUserJID{
    
    NSString *appGroupDirectoryPath = [[[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.guys"].path   stringByAppendingPathComponent:@"userinfo"] stringByAppendingPathExtension:@"txt"];
    
    NSMutableDictionary *userInfo=[NSMutableDictionary dictionaryWithContentsOfFile:appGroupDirectoryPath];
    if(!userInfo)
        return @"";
    
    return  [NSString stringWithUTF8String:gloox::JID(((NSString*)userInfo[@"jid"]).UTF8String).bare().c_str()];;
    
}

@end

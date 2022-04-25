//
//  NotificationService.m
//  GuysAppNS
//
//  Created by SARFO KANTANKA FRIMPONG on 1/7/22.
//  Copyright © 2022 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import "NotificationService.h"
#import "gloox/gloox.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import <map>
#import <iostream>
@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    self.bestAttemptContent.title = [NSString stringWithFormat:@"%@ [modified]", self.bestAttemptContent.title];
    NSString *num=self.bestAttemptContent.subtitle;
    NSString *extCod=@"1";
    NSString* tmpNum=[self getInternationalNumber:num callingCode:extCod];
    NSString* nameStr=[self getName:tmpNum];
    self.bestAttemptContent.subtitle=nameStr;
    std::cout<<"\n\n\n\n\n Notification ssssssss \n\n\n\n\n\n\n"<<std::endl;
    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

-(NSString*)getInternationalNumber:(NSString*)number callingCode:(NSString *)code{
   if(![code length] ||! number.length)
      return nil;
   NSString *tmpIntNum=[NSString stringWithString:code];
   NSString *realNumb=[[NSString alloc]init];
   for (int i=0;i<[number length];++i) {
      if([number characterAtIndex:i]>=48 &&[number characterAtIndex:i]<=57){
         realNumb=[realNumb stringByAppendingFormat:@"%c",[number characterAtIndex:i]];
      }
   }
   NSString *tmp=[NSString stringWithString:realNumb];
 
   if([tmp length]>10){
      return tmp;
   }
   tmpIntNum =[tmpIntNum stringByAppendingString:tmp];
   return tmpIntNum;
}

-(NSString*)getName:(NSString*)num1{
    
    CNContactStore * contactStore=[[CNContactStore alloc]init];
  NSArray *keyToFetch=[NSArray arrayWithObjects:[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName],CNContactGivenNameKey,CNContactPhoneNumbersKey,nil];

    NSArray<CNContainer*> *containers=[contactStore containersMatchingPredicate:nil error:nil];
 for (CNContainer *container in containers) {
    //get Contact Containers
    NSPredicate *predicate=[CNContact predicateForContactsInContainerWithIdentifier:container.identifier];
     NSArray<CNContact*>*  contacts=[contactStore unifiedContactsMatchingPredicate:predicate keysToFetch:keyToFetch error:nil];
   //add contact numbers to partners
   for (CNContact *contact in contacts) {
    
    //get contact numbers
    for (CNLabeledValue *num in contact.phoneNumbers) {
       NSString *tmpNum= [num.value stringValue];
       NSString *number=[[NSString alloc]init]; //number
       for(int i=0;i<[tmpNum length];i++){
          if(((int)[tmpNum characterAtIndex:i])>=48 && ((int)[tmpNum characterAtIndex:i])<=57){
             number=[number stringByAppendingString:[NSString stringWithFormat:@"%c",[tmpNum characterAtIndex:i]]];
          }
       }
        if([num1 isEqual:number]){
            return [contact givenName];
        }
      }
    }
 }
    return @"";
}
@end

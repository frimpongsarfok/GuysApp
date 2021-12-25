//
//  NotificationService.h
//  GuyNotiService
//
//  Created by SARFO KANTANKA FRIMPONG on 7/1/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import <UserNotifications/UserNotifications.h>
#import "gloox/jid.h"
#import "gloox/gloox.h"
#import <time.h>
#include <iostream>
@interface NotificationService : UNNotificationServiceExtension{
    NSString *m_fromJID;
    NSString *m_name;
    NSString *m_msg;
    NSString *m_category;
    NSDictionary *m_messageData;
    
}

@end

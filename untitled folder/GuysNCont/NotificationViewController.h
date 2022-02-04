//
//  NotificationViewController.h
//  GuysNCont
//
//  Created by SARFO KANTANKA FRIMPONG on 7/4/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import "NotiMessage.hpp"

@interface NotificationViewController : UIViewController<UNUserNotificationCenterDelegate,UNNotificationContentExtension>{
    NotiMessage *m_notMessage;
    UNTextInputNotificationResponse *m_resp;

}

@end

#import "NotificationViewController.h"

@interface NotificationViewController () 

@property IBOutlet UILabel *label;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UNUserNotificationCenter currentNotificationCenter]setDelegate:self];
    // Do any required interface initialization here.
    
      NSLog(@"NotificationViewController %@\n\n  ",[[[[m_resp notification]request] content] userInfo]);
   
}

- (void)didReceiveNotification:(UNNotification *)notification {
    //self.label.text = notification.request.content.body;
}
-(void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption))completion{
   
    NSString *actionId=[response actionIdentifier];
    if([actionId isEqualToString:@"REPLY"]){
        
        
       m_resp=(UNTextInputNotificationResponse*)response;
        NSString *sto=[[[[[m_resp notification] request] content] userInfo] valueForKey:@"jid"];
     
        gloox::JID to=gloox::JID(sto.UTF8String);
        m_notMessage=new NotiMessage(to);
        m_notMessage->sendMessage(self->m_resp.userText.UTF8String);
       
    }
    completion(UNNotificationContentExtensionResponseOptionDismissAndForwardAction);
}

-(void)viewWillDisappear:(BOOL)animated{
    
    
    
    
}

@end

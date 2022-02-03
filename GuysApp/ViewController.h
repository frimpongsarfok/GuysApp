//
//  ViewController.h
//  GuysApp
//
//  Created by SARFO KANTANKA FRIMPONG on 5/6/18.
//  Copyright © 2018 SARFO KANTANKA FRIMPONG. All rights reserved.
//


#import "XmppEngine.h"
#include "AppDelegate.h"
#import "ChateDelegate.h"
#import "ChatNavViewController.h"
#import "ChatCollectionViewController.h"
#import "ContactViewController.h"
#import <memory.h>
#import <MessageUI/MessageUI.h>

@class ChatsViewController;
@class ShareTableViewController;
@class ContactViewController;
@interface ViewController : UIViewController< UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,XmppProtocol,NSURLConnectionDelegate,_AppDelegate,CNContactPickerDelegate,NSURLSessionDelegate>{
    XmppEgine *m_xmppEngine;
    UIAlertController * m_actionSheet;
    BOOL m_engineCreated;
    AppDelegate *m_appDelegate;
    std::map<const std::string, gloox::RosterItem*> m_to;
    NSDateFormatter * m_dateFormater;
    AppData *m_data;
     std::future<gloox::ConnectionError> m_future;
    int m_numOfCores;
    //NSMutableArray *m_nameNNumber;
     
    //address book
    bool ContListPresRequest;
    bool ContListPresRequestUnvaliable;
    NSString * m_server;
    NSString*  m_resource;
    NSString *m_serverNResource;
    UIActivityIndicatorView *m_activityIndicator;
    UILongPressGestureRecognizer *m_deletePartnerGest;
    NSMutableArray *m_sendingFileInfos;
    NSMutableArray *m_msgID4TagNotifRef;// this area store message ID from notification for newMessageTagView() not to show to prevent duplicate Notification
 
  
    NSString *m_newDeviceToken;
    std::tuple<BOOL,std::string>m_isSearchForVCard;
@public
    id<ChatViewDelegate> m_chatDelegate;
    id<ChatShareDelegate>m_chatShareDelegate;
}



//presence view
@property (weak, nonatomic) IBOutlet UIBarButtonItem *m_presenceView;



-(void)setAccount;
@property(strong,nonatomic)NSTimer * m_timer;

@property (weak, nonatomic) IBOutlet UITableView *m_rosterTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addContact;
-(IBAction)addContact:(id) sender;
@property (weak, nonatomic) IBOutlet UILabel *m_newContNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *m_newContactName;
@property (weak, nonatomic) IBOutlet UILabel *m_newContNumberLabel;
@property (weak, nonatomic) IBOutlet UITextField *m_newContNumber;
-(void)setChatDelegate:(id<ChatViewDelegate>)delegate;
-(BOOL)storeMessage:(NSString*)_id  message:(NSString *)msg  toJIDBare:(NSString*) to fromJIDBare:(NSString*) from  textType:(AppData::MESSAGETYPE) txt_type;
-(NSString*)getInternationalNumber:(NSString*)number callingCode:(NSString *)code;

@end





// Partner

@interface PartnerTableViewCell : UITableViewCell{
@public
    UIImageView * m_photos;
    UITextView  * m_comment;
    UILabel * m_name;
  
    std::string m_jid;
    UIView *m_presenceColor;
    UILabel *m_msgeBadge;

}



-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end




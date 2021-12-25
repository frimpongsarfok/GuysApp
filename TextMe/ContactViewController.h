//
//  ContactViewController.h
//  Guys!
//
//  Created by SARFO KANTANKA FRIMPONG on 12/19/21.
//  Copyright © 2021 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "AppDelegate.h"
#import "ChatNavViewController.h"
#import "ChatCollectionViewController.h"
#import "XmppEngine.h"
#import <MessageUI/MessageUI.h>
#import <memory.h>
NS_ASSUME_NONNULL_BEGIN

@interface ContactViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,MFMessageComposeViewControllerDelegate>{
    AppData *m_data;
    AppDelegate *m_appDelegate;
     XmppEgine* m_xmppEngine;
    bool m_searching;
}
@property (weak, nonatomic) IBOutlet UISearchBar *m_searchContact;

@property (weak, nonatomic) IBOutlet UITableView *m_emailTableView;
+(void)reloadData;
@end

//Contact Partner

@interface ContactTableViewCell : UITableViewCell{
    
@public
 UILabel *m_name;
 UILabel *m_number;
 UILabel *m_invite;
    std::string jid;
 UILabel *m_background;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;


@end
NS_ASSUME_NONNULL_END

//
//  ShareTableViewController.h
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 6/5/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

//NS_ASSUME_NONNULL_BEGIN

@interface ShareTableViewController : UITableViewController<ChatShareDelegate>{
    AppDelegate *m_appDelegate;
    AppData* m_data;
    NSArray *m_shareData;
    XmppEgine* m_xmppEngine;
 
    UIActivityIndicatorView *m_activityIndicator;
    UIView *m_activityIndicatorParentView;
       gloox::JID m_partSharingDataJid;
}
-(instancetype)initWithDataArray:(NSArray*)data;
-(void)setPartnerSharingDataJID:(gloox::JID)jid;
@end


@interface ShareTableViewCell : UITableViewCell{
@public
    UILabel *m_name;
    UILabel *m_number;
    std::string jid;
    UILabel *m_background;
    UIView *m_line;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

-(void)shareDone;
@end

//NS_ASSUME_NONNULL_END

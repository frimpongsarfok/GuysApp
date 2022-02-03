//
//  ChateDelegate.h
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 5/28/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmppProtocol.h"

NS_ASSUME_NONNULL_BEGIN

//this delegate is create to send messgage to ChatViewController view if in case there is any event
@protocol ChatViewDelegate<NSObject>
-(void)handleChatRosterPresence:(const gloox::RosterItem&) item resource:(const std::string& )resource presence:(const gloox::Presence::PresenceType) presence message:(const std::string&)msg;
-(void)handleChatMessage:(const gloox::Message&)msg session:(gloox::MessageSession*)session;
-(void)handleChatMessageEvent:(const gloox::JID &)from state:(gloox::MessageEventType)event _msgiID:(NSString*)_id;
-(void)handleChatDeleted;
-(void)doneShare;
-(void)handleLastActivityResult:(const gloox::JID &)jid timeInSec:(long)seconds statusMsg:(const std::string &)status;
-(void)handlePresence:(gloox::JID )from pres:(const gloox::Presence::PresenceType )presence;
-(void)handleChatState:(const gloox::JID &)from state:(gloox::ChatStateType)state;
@end
@protocol ChatShareDelegate<NSObject>
-(void)doneShare;

@end
NS_ASSUME_NONNULL_END

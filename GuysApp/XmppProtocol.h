//
//  XmppProtocol.h
//  GuysApp
//
//  Created by SARFO KANTANKA FRIMPONG on 5/7/18.
//  Copyright © 2018 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#include "gloox/client.h"
#include <gloox/connectionlistener.h>
#include <gloox/messagefilter.h>
#include <gloox/message.h>
#include <gloox/messageeventhandler.h>
#include <gloox/messagehandler.h>
#include <gloox/messageeventfilter.h>
#include <gloox/messagesessionhandler.h>
#include <gloox/chatstatefilter.h>
#include <gloox/chatstatehandler.h>
#include <gloox/rostermanager.h>
#include <gloox/loghandler.h>
#include <gloox/rosteritem.h>
#import <gloox/registration.h>
#import <gloox/registrationhandler.h>
#include <gloox/disco.h>
#include <gloox/presence.h>
#include <gloox/connectiontls.h>
#include <gloox/connectiontcpclient.h>
#include <gloox/presencehandler.h>
#include <gloox/vcard.h>
#include <gloox/vcardmanager.h>
#include <gloox/vcardupdate.h>
#include <gloox/vcardhandler.h>
#include <gloox/adhoc.h>
#include <gloox/adhochandler.h>
#include <gloox/adhoccommandprovider.h>
#import <gloox/siprofileft.h>
#import <gloox/siprofilehandler.h>
#import <gloox/siprofilefthandler.h>
#import <gloox/bytestreamdatahandler.h>
#import <gloox/socks5bytestreamserver.h>
#import  <gloox/messageevent.h>
#import <gloox/amp.h>
//#import <gloox/lastactivity.h>
#import <gloox/lastactivityhandler.h>
#import <gloox/amp.h>
#import  <fstream>
#import <vector>
#include <iostream>
#import <exception>
#import <thread>
#import <future>
#import <chrono>
#import <gloox/error.h>
#import <gloox/privacyitem.h>
#import <gloox/privacymanager.h>
#import <gloox/privatexmlhandler.h>
#include <gloox/chatstate.h>
#include <gloox/pubsubmanager.h>
#include <gloox/receipt.h>
#include <fstream>

#include <ios>
#include "HttpFileUpload.hpp"
#include "HttpFileUploadHandler.hpp"
#import "MyLastActivity.h"
#import <Contacts/Contacts.h>
#import <ContactsUI/ContactsUI.h>
#import <AVKit/AVKit.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "MyAVPlayerViewController.h"
#import "ImageViewController.h"
#import "AudioPlayerViews.h"

/*
#import "AppDelegate.h"
#import "ReadData.h"
#import <MobileCoreServices/MobileCoreServices.h>
*/
@protocol XmppProtocol<NSObject>
@optional
-(void)handlePresence:(const gloox::Presence& )presence;
-(void)handleRoster:(const gloox::Roster&) roster;
-(void)connected;
-(void)onDisconnect:(gloox::ConnectionError )e;
-(void)handleMessage:(const gloox::Message&)msg session:(gloox::MessageSession*)session;
-(void)handleChatState:(const gloox::JID&)from state:(gloox::ChatStateType) state;

-(gloox::ConnectionError)connect;
-(void)handleLog:(NSString*)message;
-(void)handleItemAdded:(const gloox::JID& )jid;
-(void)handleItemAlreadyExist:(const gloox::JID&)jid;
-(void)handleItemSubscribed:(const gloox::JID& )jid;
-(void)handleItemUnsubscribed:(const gloox::JID& )jid;
-(void)handleItemRemoved:(const gloox::JID& )jid;
-(void)handleItemUpdated:(const gloox::JID& )jid;
-(void)handleRosterPresence:(const gloox::RosterItem&) item resource:(const std::string& )resource presence:(const gloox::Presence::PresenceType) presence message:(const std::string&)msg;
-(void)hanldeSelfPresence:(const gloox::RosterItem&) item resource:(const std::string& )resource presence:(gloox::Presence::PresenceType) presence message:(const std::string&)msg;
-(void)handleSubscriptionRequest:(const gloox::JID&)jid message:(const std::string&)msg;
-(void)handleUnsubscriptionRequest:(const gloox::JID&)jid message:(const std::string&)msg;
-(void)handleNonrosterPresence:(const gloox::Presence&) presence;
-(void)handleRosterError:( const gloox::IQ& )iq;
-(void)handleDataForm:(const gloox::JID&) from dataForm:(const gloox::DataForm&) form;
-(void)handleOOB:(const gloox::JID&) from OOB:(const gloox::OOB&) oob;
-(void)handleRegistrationResult:(const gloox::JID&) from registreationResult:(gloox::RegistrationResult) regResult;
-(void)handleAlreadyRegistered:(const gloox::JID& )from;
-(void) handleRegistrationFields:(const gloox::JID&) jid Fields:(int) fields Instruction:(std::string) instruction;
//vcard handle
-(void)handleSelfVCard:(const gloox::VCard*)card;
-(void)handleVCard:(gloox::JID)jid Card:(const gloox::VCard*)vcard;
-(void)handleSelfFetchVCardResult:(gloox::StanzaError)error;
-(void)handleFetchVCardResult:(gloox::JID)jid StanzaErr:(gloox::StanzaError)se;
-(void)handleSelfStoreVCardResult:(gloox::StanzaError)error;
-(void)handleStoreVCardResult:(gloox::JID)jid StanzaErr:(gloox::StanzaError)se;
-(void)handleSlot:(NSString *) _id fileGetUrl:(NSString*) get filePutUrl:(NSString*) put filePath:(NSString*) path fileIdentifier:(NSString*)identifier fileType:(NSString*) type;
-(void)handleSlotForPathOnly:(NSString *) _id filePath:(NSString*) path fileIdentifier:(NSString*)identifier fileType:(NSString*) type;
-(void)handlePrivacyListNames:(const std::string&) active def: (const std::string &)def privacyList:( const gloox::StringList &)lists;
-(void)handlePrivacyList: (const std::string &)name  privacyList:(const gloox::PrivacyListHandler::PrivacyList &)items;
-(void) handlePrivacyListChanged: (const std::string &)name;
-(void)handlePrivacyListResult: (const std::string &)_id result:(gloox::PrivacyListResult) plResult;

-(void) handleLastActivityResult:( const gloox::JID&) jid timeInSec: (long) seconds statusMsg:(const std::string&) status;
-(void) handleLastActivityError :( const gloox::JID&) jid errorMsg:(gloox::StanzaError) error;
//Pubsub
   /*
-(void)     handleItem: (const gloox::JID &)service itemNode: (const std::string &)node itemEntry: (const gloox::Tag*)entry);
   
-(void)     handleItems:(const std::string &id, const gloox::JID &service, const std::string &node, const gloox::PubSub::ItemList &itemList, const gloox::Error *error=0);
   
-(void)     handleItemPublication (const std::string &id, const gloox::JID &service, const std::string &node ,const gloox::PubSub::ItemList &itemList, const gloox::Error *error=0);
   
-(void)     handleItemDeletion (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::PubSub::ItemList &itemListclass , const class Error *error=0);
   
-(void)      handleSubscriptionResults (const std::string &id, const gloox::JID &service, const std::string &node, const std::string &sid, const gloox::JID &jid, const gloox::SubscriptionType subType, const gloox::Error *error=0);
   
-(void)      handleUnsubscriptionResult (const std::string &id, const gloox::JID &service, const gloox::Error *error=0);
   
-(void)      handleSubscriptionOptions (const std::string &id, const gloox::JID &service, const gloox::JID &jid, const std::string &node, const gloox::DataForm *options, const std::string &sid=EmptyString, const gloox::Error *error=0);
   
-(void)      handleSubscriptionOptionsResult (const std::string &id, const gloox::JID &service, const gloox::JID &jid, const std::string &node, const std::string &sid=EmptyString, const gloox::Error *error=0);
   
-(void)      handleSubscribers (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::PubSub::SubscriptionList &list, const gloox::Error *error=0);
   
-(void)      handleSubscribersResult (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::PubSub::SubscriberList *list, const gloox::Error *error=0);
   
-(void)      handleAffiliates (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::PubSub::AffiliateList *list, const gloox::Error *error=0);
   
-(void)      handleAffiliatesResult (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::PubSub::AffiliateList *list, const gloox::Error *error);
   
-(void)      handleNodeConfig (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::DataForm *config, const gloox::Error *error=0);
   
-(void)      handleNodeConfigResult (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::Error *error=0);
   
-(void)      handleNodeCreation (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::Error *error=0);
   
-(void)      handleNodeDeletion (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::Error *error=0);
   
-(void)      handleNodePurge (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::Error *error=0);
   
-(void)      handleSubscriptions (const std::string &id, const gloox::JID &service, const gloox::PubSub::SubscriptionMap &subMap, const gloox::Error *error=0);
   
-(void)     handleAffiliations (const std::string &id, const gloox::JID &service, const gloox::PubSub::AffiliationMap &affMap, const gloox::Error *error=0);
   
-(void)      handleDefaultNodeConfig (const std::string &id, const gloox::JID &service, const gloox::DataForm *config, const gloox::Error *error=0);
    
    
    */
@end





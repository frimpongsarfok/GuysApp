//
//  XmppEngine.hpp
//  GuysApp
//
//  Created by SARFO KANTANKA FRIMPONG on 5/6/18.
//  Copyright © 2018 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#ifndef XmppEngine_h
#define XmppEngine_h
#import <UIKit/UIKit.h>
#import "XmppProtocol.h"
#import <gloox/parser.h>
#import <gloox/iq.h>
#import <gloox/iqhandler.h>
#include "HttpFileUpload.hpp"
#include <chrono>
#include <tuple>
#import <gloox/tag.h>
#include <gloox/pubsubresulthandler.h>
class MyVCard:public gloox::VCard{
    static gloox::VCard *m_vcard;
public:
    MyVCard(gloox::VCard* vc){
        MyVCard::m_vcard=vc;
    }
};



class HttpFileUpload;
class MyChatStateHandler;
/*
class MyMessageSession:public gloox::MessageSession{
public:
    //using gloox::MessageSession::send;
    void send(const std::string& msg,const std::string&subject,const StanzaExtensionList& sel){
        //check if there is a message add event extension if not then
        //the message sending is an event to a partner
       // if(m_parent)
        
        //gloox::MessageSession::send(msg.body(),msg.subject());;//,{gloox::StanzaExtensionType::ExtChatState,gloox::StanzaExtensionType::ExtMessageEvent});
        MessageSession::send(msg, subject, sel );
       
       
    }

     
};*/


class XmppEgine:public gloox::ConnectionListener,
   gloox::LogHandler,
gloox::RosterListener,
gloox::PresenceHandler,
gloox::MessageSessionHandler,
gloox::MessageHandler,
gloox::ChatStateHandler,
gloox::RegistrationHandler,
gloox::VCardHandler,
gloox::AdhocCommandProvider,
gloox::AdhocHandler,
gloox::BytestreamDataHandler,
gloox::SIProfileFTHandler,
gloox::IqHandler,HttpFileUploadHandler,
gloox::PrivacyListHandler,
gloox::LastActivityHandler,
gloox::TagHandler,
gloox::PubSub::ResultHandler
{
  
    
    gloox::PrivacyManager *m_privacyManager;
    gloox::PrivacyListHandler::PrivacyList m_partnerBlockList;
    
    std::thread connectionThread;
    gloox::PubSub::Manager *m_pubsubMang;
    gloox::Presence m_presence;
    gloox::Client *m_client;
    gloox::Client *m_clientContactRes;
    gloox::ConnectionError m_err;
    id<XmppProtocol> m_delegate;
  
    
    //store file
    std::map<std::string/*file msgID*/, std::string/*message*/> m_Ar4FileURL4Noti;
    bool m_clientConnected;
    bool  m_appRunning=false;
    gloox::VCard *m_vcard;
    std::future<bool>m_future;
    gloox::ConnectionTLS* m_tls;
    gloox::ConnectionTCPClient* m_tcpClient;
    gloox::VCardManager * m_vcardManager;
    bool m_running;
    gloox::JID m_myJID;
    //Client Device token
     std::string m_deviceToken;
    gloox::Adhoc *m_adhocCommand;
    //ip and port
    std::pair< std::string,int> m_ipNport;

    //file
    gloox::SIProfileFT *m_siprofilteFT;
    std::vector<std::vector<std::string>> m_sendFiles64data;
    gloox::SOCKS5BytestreamServer* m_sockServer;
    gloox::SOCKS5BytestreamManager *m_sockManager;
    std::vector<gloox::Bytestream>  *m_sendingByteStreams;
    std::list<gloox::Bytestream*>m_streams;
    
    //thread

    bool m_sock5Serverlistening;
   bool m_listeningToStreams;
    struct FILE{
        std::string m_file;
        int size;
        std::string type;
    };
    
    void setIpNPort(const std::string& msg);
    std::string m_server;
    
   
    gloox::Parser *m_parser;
    dispatch_queue_t m_connectThread;
    
    
public:
    typedef std::tuple<gloox::MessageSession*,gloox::MessageEventFilter*/*null because it is deprecate from  XMPP */,gloox::ChatStateFilter*>  MessageSessionInfoType;
    typedef std::vector<MessageSessionInfoType> MessageSessionType;
    std::tuple<std::string/*path*/,std::string/*url*/,std::string/*put*/,std::string/*identifier*/,std::string/*msg_ID*/> m_fileSendingInfo;
    MyLastActivity *m_lastActivityManager;
    
    HttpFileUpload *m_fileTransferManager;

      MessageSessionType m_sessions;
  
    //pubsub
    
    enum PUBSUB_NOTI_TYPE{PROFILE_UPDATE=1};

    void disconnect(){
        try {
            if(m_client){
               // m_sockServer->stop();
                m_appRunning=false;
             
                
                //dispatch_sync(dispatch_queue_create("disconnect",nullptr), ^{
                //    m_client->disconnect();
                //});
                    //dispatch_async(dispatch_get_main_queue(), ^{
               
                return;
            }
        } catch (std::exception ex) {
            std::cout<<"Disconnect excep:"<<ex.what()<<std::endl;
        }

       
        
    }
    
    //Privacy
    void addPartnertoPrivacyList(gloox::JID){
        
    }
    void blockPartner(gloox::JID jid){
        if(clientIsconnected() && m_privacyManager){
            gloox::PrivacyItem item(gloox::PrivacyItem::TypeJid,gloox::PrivacyItem::ActionDeny,gloox::PrivacyItem::PacketAll,jid.bare());
            m_partnerBlockList.remove_if([jid](gloox::PrivacyItem item){
                return item.value()==jid.bare();
            });
            m_partnerBlockList.push_back(item);
            m_privacyManager->store("PartnerBlockedList",m_partnerBlockList);
        }
      
    }
    void unblockPartner(gloox::JID jid){
        if(clientIsconnected() && m_privacyManager){
            gloox::PrivacyItem item(gloox::PrivacyItem::TypeJid,gloox::PrivacyItem::ActionAllow,gloox::PrivacyItem::PacketAll,jid.bare());
            m_partnerBlockList.remove_if([jid](gloox::PrivacyItem item){
                return item.value()==jid.bare();
            });
            m_partnerBlockList.push_back(item);
            m_privacyManager->store("PartnerBlockedList",m_partnerBlockList);
        }
      
    }
    void getServerBlockedPartList(){
        m_privacyManager->requestList("PartnerBlockedList");
    }
    std::vector<gloox::PrivacyItem> getPartnerBlockList(){
        std::vector<gloox::PrivacyItem> list={};
        for(gloox::PrivacyItem item:m_partnerBlockList){
            if(item.action()==gloox::PrivacyItem::ActionDeny){
                list.push_back(item);
            }
        }
        return list;
    
    }
    bool isPartnerBlocked(gloox::JID jid){
        for(gloox::PrivacyItem item:m_partnerBlockList){
            if(jid.bare()==item.value() && item.action()==gloox::PrivacyItem::ActionDeny){
                return true;
            }
        }
        return false;
    }
    virtual void    handlePrivacyListNames (const std::string &active, const std::string &def, const gloox::StringList &lists);
    
    virtual void    handlePrivacyList (const std::string &name, const gloox::PrivacyListHandler::PrivacyList &items);
    
    virtual void    handlePrivacyListChanged (const std::string &name);
    
    virtual void   handlePrivacyListResult (const std::string &id, gloox::PrivacyListResult plResult);
    
    virtual void handleTag    (    gloox::Tag *     tag    );

    
  //Pubsub
    
    const  gloox::JID getPubsubNotificationServiceName(){
        return gloox::JID("pubsub."+getMyJID().server());
    }
    const std::string getPubsubNodeName(){
        return  std::string("notification_node_"+getMyJID().username());
    }
     void getPartnerNodeConfig(const gloox::JID jid){
        m_pubsubMang->getNodeConfig(getPubsubNotificationServiceName(),"notification_node_"+jid.username(), this);
    }

    void createNotificationNode(){
        if(!m_pubsubMang  || !clientIsconnected())return;
        gloox::DataForm *m_notiNodeConfigForm=new gloox::DataForm(gloox::FormType::TypeSubmit);
        m_notiNodeConfigForm->addField(gloox::DataFormField::TypeBoolean,"pubsub#presence_based_delivery","1");
        m_notiNodeConfigForm->addField(gloox::DataFormField::TypeTextSingle,"pubsub#max_items","1");
        m_pubsubMang->createNode(getPubsubNotificationServiceName(), getPubsubNodeName(), m_notiNodeConfigForm, this);
    }
    void subscribToNodeItemNoti(gloox::JID jid){
        if(m_pubsubMang && clientIsconnected())
            m_pubsubMang->subscribe(getPubsubNotificationServiceName(), "notification_node_"+jid.username(), this,gloox::JID(),gloox::PubSub::SubscriptionItems);
    }
    void publishNotification(PUBSUB_NOTI_TYPE type, std::string title={}, std::string content={}){
        if(!m_pubsubMang)return;
         gloox::Tag *itemTag=new gloox::Tag("notification");
        itemTag->addAttribute("type" ,type);
        itemTag->addAttribute("jid" ,getMyJID().bare());
        new  gloox::Tag(itemTag,"title",title);
        new gloox::Tag(itemTag,"content",content);
        gloox::PubSub::Item *item=new gloox::PubSub::Item();
        item->setPayload(itemTag);
        gloox::PubSub::ItemList list;
        list.push_back(item);
        std::cout<<" publish item -> "<<item->payload()->xml()<<std::endl;
        
        m_pubsubMang->publishItem(getPubsubNotificationServiceName(), getPubsubNodeName(),list, nullptr, this);
        
    }
    
    virtual void     handleItem (const gloox::JID &service, const std::string &node, const gloox::Tag *entry);
     
    virtual void     handleItems (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::PubSub::ItemList &itemList, const gloox::Error *error=0);
     
    virtual void     handleItemPublication (const std::string &id, const gloox::JID &service, const std::string &node ,const gloox::PubSub::ItemList &itemList, const gloox::Error *error=0);
     
    virtual void     handleItemDeletion (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::PubSub::ItemList &itemListclass , const class gloox::Error *error=0);

    virtual void     handleSubscriptionResult (const std::string &id, const gloox::JID &service, const std::string &node, const std::string &sid, const gloox::JID &jid, const gloox::PubSub::SubscriptionType subType, const gloox::Error *error=0);
     
    virtual void     handleUnsubscriptionResult (const std::string &id, const gloox::JID &service, const gloox::Error *error=0);
     
    virtual void     handleSubscriptionOptions (const std::string &id, const gloox::JID &service, const gloox::JID &jid, const std::string &node, const gloox::DataForm *options, const std::string &sid=gloox::EmptyString, const gloox::Error *error=0);
     
    virtual void     handleSubscriptionOptionsResult (const std::string &id, const gloox::JID &service, const gloox::JID &jid, const std::string &node, const std::string &sid= gloox::EmptyString, const gloox::Error *error=0);
     
    virtual void     handleSubscribers (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::PubSub::SubscriptionList &list, const gloox::Error *error=0);
     
    virtual void     handleSubscribersResult (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::PubSub::SubscriberList *list, const gloox::Error *error=0);
     
    virtual void     handleAffiliates (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::PubSub::AffiliateList *list, const gloox::Error *error=0);
    
     
    virtual void     handleAffiliatesResult (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::PubSub::AffiliateList *list, const gloox::Error *error);
     
    virtual void     handleNodeConfig (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::DataForm *config, const gloox::Error *error=0);
     
    virtual void     handleNodeConfigResult (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::Error *error=0);
     
    virtual void     handleNodeCreation (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::Error *error=0);
     
    virtual void     handleNodeDeletion (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::Error *error=0);
     
    virtual void     handleNodePurge (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::Error *error=0);
     
    virtual void     handleSubscriptions (const std::string &id, const gloox::JID &service, const gloox::PubSub::SubscriptionMap &subMap, const gloox::Error *error=0);
     
    virtual void     handleAffiliations (const std::string &id, const gloox::JID &service, const gloox::PubSub::AffiliationMap &affMap, const gloox::Error *error=0);
     
    virtual void     handleDefaultNodeConfig (const std::string &id, const gloox::JID &service, const gloox::DataForm *config, const gloox::Error *error=0);
     
   /* gloox::Presence getPresence(){
        try{
        if(m_client)
           return  gloox::Presence(m_client->presence().presence(),m_client->presence().to(),m_client->presence().status(),m_client->presence().presence());
        }catch(std::exception *ext){
            return gloox::Presence(gloox::Presence::Unavailable,gloox::JID(),std::string(),0);
        }
  
        return gloox::Presence(gloox::Presence::Unavailable,gloox::JID(),std::string(),0);

        
    }*/
    enum Data{SERVER,JID,PASSWORD};
    gloox::JID m_to;
     UIImage *m_topImage;

           
    
   const gloox::JID getMyJID()const{
        return m_myJID;
       
   }
    const gloox::JID getToJID()const{

        return m_to;
    }

    bool handleIq (const gloox::IQ &iq);
    void handleIqID (const gloox::IQ &iq, int context);
    void setToJId(const gloox::JID to){
        m_to=to;
    }
    bool clientIsconnected(){
        return m_clientConnected;
    }
    void setDelegate(id delegate){
        if(delegate)
            m_delegate=delegate;
        
    }
    
    //connection
    virtual void onConnect();
    virtual void onDisconnect(gloox::ConnectionError e);
    virtual bool onTLSConnect(const  gloox::CertInfo& info);

    //vcard
    gloox::VCardManager* getVCardManager(){
        return m_vcardManager;
    }
    const gloox::VCard* getMyVCard(){
        return m_vcard;
    }
    void fetchVCard(const gloox::JID from){
        try{
            if(m_appRunning){
               // std::thread([this,from]{
                    m_vcardManager->fetchVCard(from.bare(), this);
                    //std::this_thread::sleep_for(std::chrono::seconds(1));
               // }).detach();
            }
        }catch(std::exception ex){
            
        }

    }
   // template<class Excep>
    void storeVCard(gloox::VCard* card){
        try{
            if(!clientIsconnected())
                return;
            if(m_appRunning && m_vcardManager)
                m_vcardManager->storeVCard(card,this);
        }
        catch(std::exception  cppException){
            
        }
     
    }
    virtual void handleVCard(const gloox::JID& jid,const gloox::VCard* vcard);
    virtual void handleVCardResult (VCardContext context, const gloox::JID &jid, gloox::StanzaError se=gloox::StanzaErrorUndefined);
    
    //roster
    void refreshRoster();
    virtual void handleItemAdded( const gloox::JID& jid );
    virtual void handleItemSubscribed( const gloox::JID& jid );
    virtual void handleItemRemoved( const gloox::JID& jid );
    virtual void handleItemUpdated( const gloox::JID& jid );
    virtual void handleItemUnsubscribed( const gloox::JID& jid );
    virtual void handleRoster( const gloox::Roster& roster );
    virtual void handleRosterPresence( const gloox::RosterItem& item, const std::string& resource,
                                      gloox::Presence::PresenceType presence, const std::string& msg );
    virtual void handleSelfPresence( const gloox::RosterItem& item, const std::string& resource,
                                    gloox::Presence::PresenceType presence, const std::string& msg );
    virtual bool handleSubscriptionRequest( const gloox::JID& jid, const std::string& msg );
    virtual bool handleUnsubscriptionRequest( const gloox::JID& jid, const std::string& msg );
    virtual void handleNonrosterPresence( const gloox::Presence& presence );
    virtual void handleRosterError( const gloox::IQ& iq );
    //lastactivity
    virtual void handleLastActivityResult( const gloox::JID& jid, long seconds, const std::string& status );
    virtual void handleLastActivityError( const gloox::JID& jid, gloox::StanzaError error );
    
    bool addPartnerToRoster(const gloox::JID jid){
      
       
        if(!m_client||!getRoster())
            return false;
        
        bool found=false;

        for(auto item:*getRoster()->roster()){
            if(gloox::JID(jid).bare()==gloox::JID(item.first).bare()){
                found=true;
                if(item.second->subscription()==gloox::SubscriptionType::S10nToIn ||
                   item.second->subscription()==gloox::SubscriptionType::S10nFrom){
                    m_client->rosterManager()->subscribe(jid);
                }
            }
                
        }

       if(!found){
            m_client->rosterManager()->subscribe(jid);
        }
        return true;
        
    }

    virtual void handleSendFileResult(HttpFileUploadHandler::HttpFileUploadResult result);

    virtual void handleSlot(const std::string _id,const std::string slot,const std::string fileID,SLOTTYPE type,const std::string filetype,bool resend);

    bool removeContact(const gloox::JID& jid){
        if(!jid)
            return false;
        m_client->rosterManager()->remove(jid);
        
        std::map<const std::string,gloox::RosterItem*>::const_iterator it0=getRoster()->roster()->find(jid.bare());
        if(it0->second)
              getRoster()->roster()->erase(it0);// delete from roster var in client
        return true;
    }
    
    //messages
    enum class MESSAGETYPE{TEXT=1,FILE_ASSET_ID=2,FILE_URL=3,WEB_LINK=4,REPLY=5,DELETE=6,RECEIPT=7};
    std::string getID(){
      if(!m_client)
          return {};
      return m_client->getID();
    }
    //const char* MESSAGETYPE_STR[7]={"-","TEXT","IMG_URL","VIDEO_URL","IMG_PATH","VID_PATH","WEB_LINK"};
    std::vector<const std::string> IMAGE_TYPE{"bmp","gif","jpeg","jpg","xbm","dib","webp","ico","tiff","tif"};
     std::vector<const std::string> VIDEO_TYPE{"mov","mp4","m4v","3gp"};
    virtual void handleMessage( const gloox::Message& msg, gloox::MessageSession* session = 0 );
    virtual void handleChatState( const gloox:: JID& from,gloox:: ChatStateType state );
    virtual void handleMessageSession(gloox::MessageSession* session );
    void createMessageSesstion(const gloox::JID jid);

    MessageSessionInfoType getMessageSessionChatState(const gloox::JID jid){
        for (auto ss: m_sessions) {
            if(!std::get<0>(ss)){
                continue;
            }else if(std::get<0>(ss)->target().bare()==jid.bare()){
                return ss;
            }
        }
        return  {nullptr,nullptr,nullptr};
    }
    MessageSessionInfoType createMessageSessionChatState(const gloox::JID to){
        if(!clientIsconnected()){
            return {nullptr,nullptr,nullptr};
        }
        gloox::MessageSession*session = new gloox::MessageSession(m_client, to);
        session->registerMessageHandler(this);
        auto chatState=new gloox::ChatStateFilter(session);
        chatState->registerChatStateHandler(this);
     
        m_sessions.push_back({session,nullptr,chatState});
        return m_sessions[m_sessions.size()-1];
    }
    void sendMessage(MESSAGETYPE type,const std::string msg, const std::string _id,const std::string _to,BOOL resend=NO){
        if( _to.empty()){
            return;
        }
        
        gloox::JID tmpTo(_to);
        gloox::Message tmpMsg(gloox::Message::Chat,tmpTo,msg,(std::to_string((int)type)+" "+_id));
        tmpMsg.setFrom(getMyJID());
        tmpMsg.setID(_id);
        MessageSessionInfoType ss=getMessageSessionChatState(tmpTo);
        if((std::get<0>(ss)==nullptr) && clientIsconnected()){
            ss=createMessageSessionChatState(tmpTo);
        }
        if(type==MESSAGETYPE::RECEIPT){

                    if(clientIsconnected()){
                        std::get<0>(ss)->send(msg,
                                              (std::to_string((int)type)+" "+_id),
                                           {new gloox::Receipt(gloox::Receipt::Received,_id)
                            
                        });
                    }

                  
        }else{
            if(clientIsconnected()&& type!=MESSAGETYPE::FILE_ASSET_ID){
                std::get<0>(ss)->send(msg,
                                   (std::to_string((int)type)+" "+_id),
                                   {new gloox::Receipt(gloox::Receipt::Request,_id)
                });
                tmpMsg.addExtension(new gloox::Receipt(gloox::Receipt::Request,_id));
                 handleMessage(tmpMsg, std::get<0>(ss));
            }else{
                tmpMsg.addExtension(new gloox::Receipt(gloox::Receipt::Request,_id));
                handleMessage(tmpMsg, nullptr);
            }
       
        }
        
    }
         

    //presence
    virtual void handlePresence( const gloox::Presence& presence );
    
    //log
    virtual void handleLog( gloox::LogLevel level, gloox::LogArea area, const std::string& message );
    
    gloox::RosterManager* getRoster(){
      if(m_client)
        return m_client->rosterManager();
        
        return nullptr;
    }
    bool connect();

    
    XmppEgine(id delegate, const std::string user_jid,const std::string pwd, const std::string server,bool forContactRes);

    //Create Account
    gloox::Registration *m_registration;
    XmppEgine(id delegate,const std::string& server);
    
    
    bool registrationMode;
    virtual void handleRegistrationResult(const gloox::JID& from,gloox::RegistrationResult result);
    virtual void handleRegistrationFields(const gloox::JID& jid,int fiedls, std::string instruction);
    virtual void handleDataForm(const gloox::JID& jid,const gloox::DataForm& data);
    virtual void handleOOB(const gloox::JID& jid,const gloox::OOB& oob);
    virtual void handleAlreadyRegistered(const gloox::JID& from);
    void registerAccount(const std::string userName,const std::string password);
    void fetchFields();
    bool deleteAccount();
    const std::string getServer(){
        return m_server;
    }
  
    
    ~XmppEgine() {
      
      
          
            if(m_delegate)
                m_delegate=Nil;
            
              if(m_vcardManager){
                 delete m_vcardManager;
                m_vcardManager=nullptr;
             }
            if(m_registration){
                delete m_registration;
                m_registration=nullptr;
            }
            
            if( m_parser){
                       delete m_parser;
            }
            m_parser=nullptr;

        if( m_privacyManager){
            delete m_privacyManager;
            m_privacyManager=nullptr;
        }
            
           //if(m_myevent)
             //  delete  m_myevent;
            if(m_fileTransferManager)
                delete m_fileTransferManager;
            m_fileTransferManager=nullptr;
           // m_myevent=nil;
            
            if(m_sessions.size()){
                for (auto ss: m_sessions) {
                   // delete std::get<1>(ss);
                    std::get<1>(ss)=nullptr;
                    //std::get<0>(ss)->disposeMessageFilter(std::get<2>(ss));
                    //m_client->disposeMessageSession(std::get<0>(ss));
                    std::get<0>(ss)=nullptr;
                    std::get<2>(ss)=nullptr;

                  
                }
                m_sessions.clear();
               
            }
            for(gloox::Bytestream *stream:m_streams)
                m_siprofilteFT->dispose(stream);
            if(m_siprofilteFT){
                delete m_siprofilteFT;
                m_siprofilteFT=nullptr;
            }
            if(m_lastActivityManager){
                delete m_lastActivityManager;
                m_lastActivityManager=nullptr;
            }
     
                
         m_clientConnected=false;
        m_appRunning=false;
            if(m_client){
     
                disconnect();
               // delete m_client;
               // m_client=nullptr;
            }
       
                std::cout<<"xmppEngine deleted"<<std::endl;
        
               
            
        
        
      
      


  
   
     
    
    }
   
    void registerDeviceToken(std::string token);
    //adhoc
    
    virtual void     handleAdhocCommand (const gloox::JID &from, const gloox:: Adhoc::Command &command, const std::string &sessionID);
    
    virtual bool     handleAdhocAccessRequest (const gloox::JID &from, const std::string &command);
    virtual void     handleAdhocSupport (const gloox::JID &remote, bool support, int context);
    
    virtual void     handleAdhocCommands (const gloox::JID &remote, const gloox::StringMap &commands, int context);
    
    virtual void     handleAdhocError (const gloox::JID &remote, const gloox::Error *error, int context);
    
    virtual void     handleAdhocExecutionResult (const gloox::JID &remote, const gloox::Adhoc::Command &command, int context);
    
    
    virtual void handleFTRequestResult( const gloox::JID& /*from*/, const std::string& /*sid*/ );
    
    virtual void handleFTRequestError( const gloox::IQ& /*iq*/, const std::string& /*sid*/ );
    
    virtual void handleFTBytestream(gloox::Bytestream* bs );
    
    virtual const std::string handleOOBRequestResult( const gloox::JID& /*from*/, const gloox::JID& /*to*/, const std::string& /*sid*/ );;
    
    virtual void handleBytestreamData( gloox::Bytestream* /*bs*/, const std::string& data );
    
    virtual void handleBytestreamError(gloox:: Bytestream* /*bs*/, const gloox::IQ& /*iq*/ );
    
    virtual void handleBytestreamOpen( gloox::Bytestream* /*bs*/ );
    
    virtual void handleBytestreamClose( gloox::Bytestream* /*bs*/ );
    virtual void handleFTRequest( const gloox::JID& from, const gloox::JID& /*to*/, const std::string& sid,
                                    const std::string& name, long size, const std::string& hash,
                                    const std::string& date, const std::string& mimetype,
                                 const std::string& desc, int /*stypes*/ );
};
//
//class MyChatStateHandler:public gloox::LogHandler,gloox::TagHandler{
//    
//   
//public:
//    
//    MyChatStateHandler(gloox::Client *parent, XmppEgine *handler):m_client(parent),m_parser(new gloox::Parser(this,YES)),m_handler(handler){
//        m_client->logInstance().registerLogHandler(gloox::LogLevelDebug, gloox::LogAreaXmlIncoming,this);
//    }
//    virtual void handleTag(gloox::Tag *tag){
//        if(!m_handler){
//            m_parser->cleanup();
//            return;
//        }
//        
//        
//        if(tag->name()!="message"){
//            m_parser->cleanup();
//            return;
//        }
//        if(!tag->hasChild("body")){
//            std::string from=std::string();
//            from=tag->findAttribute("from");
//            for(auto child: tag->children()){
//              
//                if(child->name()=="gone"){
//                    m_handler->handleChatState(from, gloox::ChatStateGone);
//                }else if(child->name()=="composing"){
//                    m_handler->handleChatState(from, gloox::ChatStateComposing);
//                }
//                else if(child->name()=="paused"){
//                    m_handler->handleChatState(from, gloox::ChatStatePaused);
//                }
//                else if(child->name()=="invalid"){
//                    m_handler->handleChatState(from, gloox::ChatStateInvalid);
//                }
//               
//            }
//        }
//        
//     
//            m_parser->cleanup();
//    }
//           
//           
//virtual void handleLog( gloox::LogLevel level, gloox::LogArea area, const std::string& message ){
//        
//        
//    if(!m_parser)
//            return;
//        std::string tmpLog(message);
//     if(area==gloox::LogAreaXmlIncoming){
//        m_parser->feed(tmpLog);
//    }
//    
//
//        
//        
//        
//    }
//    
//~MyChatStateHandler(){
//        if( m_parser){
//            delete m_parser;
//        }
//        m_parser=nullptr;
//
//        m_handler=nil;
//    }
//private:
//    gloox::Parser *m_parser;
//    XmppEgine *m_handler;
//    gloox::Client *m_client;
//   
//};


#endif /* XmppEngine_hpp */

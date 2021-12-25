//
//  XmppEngine.hpp
//  Guys!
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

#include <gloox/pubsub.h>
#include <gloox/pubsubresulthandler.h>
class MyVCard:public gloox::VCard{
    static gloox::VCard *m_vcard;
public:
    MyVCard(gloox::VCard* vc){
        MyVCard::m_vcard=vc;
    }
};


class MyMessageEvent;
class HttpFileUpload;
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
// gloox::TagHandler,
gloox::PubSub::ResultHandler
{
  
    
    gloox::PrivacyManager *m_privacyManager;
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
    gloox::VCard *m_vcard;
    std::future<bool>m_future;
    gloox::ConnectionTLS* m_tls;
    gloox::ConnectionTCPClient* m_tcpClient;
    gloox::VCardManager * m_vcardManager;
    bool m_running;
    //Client Device token
     std::string m_deviceToken;
    gloox::Adhoc *m_adhocCommand;
    //ip and port
    std::pair< std::string,int> m_ipNport;
    
    //delege
    
    //file
    gloox::SIProfileFT *m_siprofilteFT;
    std::vector<std::vector<std::string>> m_sendFiles64data;
    gloox::SOCKS5BytestreamServer* m_sockServer;
    gloox::SOCKS5BytestreamManager *m_sockManager;
    std::vector<gloox::Bytestream>  *m_sendingByteStreams;
    std::list<gloox::Bytestream*>m_streams;
    
    //thread

    std::tuple<std::string/*path*/,std::string/*url*/,std::string/*put*/,std::string/*identifier*/,std::string/*msg_ID*/> m_fileSendingInfo;
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
    
public:
    
    MyLastActivity * m_lastActivity;
    HttpFileUpload *m_fileTransferManager;
 //messageevent handler parser
    
   // MyMessageEvent *m_myevent;
      std::vector<std::tuple<gloox::MessageSession*,gloox::MessageEventFilter*,gloox::ChatStateFilter*>> m_sessions;
    /*
    const std::string getIp()const{
        if(m_ipNport!= std::pair(std::string(),0)){
           return m_ipNport.first;
        }
        return std::string();
    }
    const int getPort()const{
        if(m_ipNport!=std::pair(std::string(),0)){
            return m_ipNport.second;
        }
        return 0;
    }*/
    
    void sendSelfPresenceToRosterMemb(){
        std::time_t ct = std::time(0);
        char* cc = ctime(&ct);
        if(m_clientConnected){
            for(auto ros:*m_client->rosterManager()->roster()){
                if(!ros.second->online()){
                    gloox::Presence pre(gloox::Presence::PresenceType::Unavailable,ros.second->jidJID(),cc);
                    m_client->send(pre);
                }
            }
            
        }
            
            
      
    }
    void disconnect(){
        try {
            if(m_clientConnected && m_client){
               // m_sockServer->stop();
                m_clientConnected=false;
               // std::this_thread::sleep_for(std::chrono::seconds(2x));
                m_client->disconnect();
               
                return;
            }
        } catch (std::exception ex) {
            std::cout<<"Disconnect excep:"<<ex.what()<<std::endl;
        }

       
        
    }
    
    //Privacy
    virtual void    handlePrivacyListNames (const std::string &active, const std::string &def, const gloox::StringList &lists);
    
    virtual void    handlePrivacyList (const std::string &name, const gloox::PrivacyListHandler::PrivacyList &items);
    
    virtual void    handlePrivacyListChanged (const std::string &name);
    
    virtual void   handlePrivacyListResult (const std::string &id, gloox::PrivacyListResult plResult);
    
    //virtual void handleTag    (    gloox::Tag *     tag    );

    
  //Pubsub
     
    virtual void     handleItem (const gloox::JID &service, const std::string &node, const gloox::Tag *entry);
     
    virtual void     handleItems (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::PubSub::ItemList &itemList, const gloox::Error *error=0);
     
    virtual void     handleItemPublication (const std::string &id, const gloox::JID &service, const std::string &node ,const gloox::PubSub::ItemList &itemList, const gloox::Error *error=0);
     
    virtual void     handleItemDeletion (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::PubSub::ItemList &itemListclass , const class Error *error=0);

    virtual void     handleSubscriptionResult (const std::string &id, const gloox::JID &service, const std::string &node, const std::string &sid, const gloox::JID &jid, const gloox::PubSub::SubscriptionType subType, const gloox::Error *error=0);
     
    virtual void     handleUnsubscriptionResult (const std::string &id, const gloox::JID &service, const gloox::Error *error=0);
     
    virtual void     handleSubscriptionOptions (const std::string &id, const gloox::JID &service, const gloox::JID &jid, const std::string &node, const gloox::DataForm *options, const std::string &sid=EmptyString, const gloox::Error *error=0);
     
    virtual void     handleSubscriptionOptionsResult (const std::string &id, const gloox::JID &service, const gloox::JID &jid, const std::string &node, const std::string &sid=EmptyString, const gloox::Error *error=0);
     
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
       if(!m_client)
           return gloox::JID();
        return m_client->jid();
       
   }
    const gloox::JID getToJID()const{
        
        return m_to;
    }
    void clientContactUpdater(){
        std::string jid=getMyJID().bare();
        m_clientContactRes=new gloox::Client(jid+"/contactResouce",getMyJID().username());
        m_clientContactRes->setPort(5222);
        m_clientContactRes->registerPresenceHandler(this);
       // std::thread([this]{
            m_clientContactRes->connect();
       // }).detach();
        
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
            if(this->m_client->state()==gloox::ConnectionState::StateConnected ){
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
            
            if(m_client && m_vcardManager)
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
      
       
        if(!m_client||!m_client->rosterManager())
            return false;
        
        bool found=false;
        for(auto& item:*getRoster()->roster()){
            if(gloox::JID(jid).bare()==gloox::JID(item.first).bare())
                found=true;
        }
     
    
       if(!found){
           
            m_client->rosterManager()->add(jid, jid.username(), gloox::StringList());
            m_client->rosterManager()->subscribe(jid);
            m_client->rosterManager()->ackSubscriptionRequest(jid.bare(), true);
            ///m_client->rosterManager()->fill();
           
            return true;
        }
        return false;
        
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
    enum class MESSAGETYPE{TEXT=1,FILE_ASSET_ID=2,FILE_URL=3,YOUTUBE_LINK=4,REPLY=5,DELETE=6,RECEIPT=7};
    //const char* MESSAGETYPE_STR[7]={"-","TEXT","IMG_URL","VIDEO_URL","IMG_PATH","VID_PATH","YOUTUBE_LINK"};
    std::vector<const std::string> IMAGE_TYPE{"bmp","gif","jpeg","jpg","xbm","dib","webp","ico","tiff","tif"};
     std::vector<const std::string> VIDEO_TYPE{"mov","mp4","m4v","3gp"};
    virtual void handleMessage( const gloox::Message& msg, gloox::MessageSession* session = 0 );
                 //this is created beacase default out going message has no id
    void myHandleMessage( const gloox::Message& msg, gloox::MessageSession* session=nullptr);
    virtual void handleChatState( const gloox:: JID& from,gloox:: ChatStateType state );

    
    virtual void handleMessageSession(gloox::MessageSession* session );
    void createMessageSesstion(const gloox::JID jid);
    std::string getID(){
        return m_client->getID();
    }
    void sendMessage(MESSAGETYPE type,const std::string msg, const std::string _id,const std::string _to,BOOL resend=NO){
        if( _to.empty()){
            return;
        }
            bool found=NO;
            gloox::JID tmpTo(_to);
        gloox::Message tmpMsg(gloox::Message::Chat,tmpTo,msg,(std::to_string((int)type)+" "+_id));
        tmpMsg.setFrom(getMyJID());
        tmpMsg.setID(_id);
                for (auto ss: m_sessions) {
                    if(std::get<0>(ss)->target()==_to ){
                        found=YES;
                        switch(type){
                            case MESSAGETYPE::TEXT:{
                                 std::get<0>(ss)->send(msg,
                                                    (std::to_string((int)type)+" "+_id),
                                                    {new gloox::Receipt(gloox::Receipt::Request,_id)
                                 });
                                tmpMsg.addExtension(new gloox::Receipt(gloox::Receipt::Request,_id));
                                this->handleMessage(tmpMsg, std::get<0>(ss));
                                break;
                            }
                            case MESSAGETYPE::FILE_ASSET_ID: {
                                std::get<0>(ss)->send(msg,
                                                      (std::to_string((int)type)),
                                                   {new gloox::ChatState(gloox::ChatStateActive),new gloox::Receipt(gloox::Receipt::Request,_id)
                                    
                                });
                                   tmpMsg.addExtension(new gloox::ChatState(gloox::ChatStateActive));
                                   tmpMsg.addExtension(new gloox::Receipt(gloox::Receipt::Request,_id));
                                this->handleMessage(tmpMsg, std::get<0>(ss));
                                    break;
                                }
                                case MESSAGETYPE::FILE_URL: {
                                    std::get<0>(ss)->send(msg,
                                                          (std::to_string((int)type)),
                                                       {new gloox::ChatState(gloox::ChatStateActive),new gloox::Receipt(gloox::Receipt::Request,_id)
                                    });
                                       
                                       tmpMsg.addExtension(new gloox::ChatState(gloox::ChatStateActive));
                                       tmpMsg.addExtension(new gloox::Receipt(gloox::Receipt::Request,_id));
                                        std::get<0>(ss)->handleMessage(tmpMsg);
                                    break;
                                }
                            case MESSAGETYPE::YOUTUBE_LINK: {
                                    
                                 std::get<0>(ss)->send(msg,
                                                       (std::to_string((int)type)),
                                                    {new gloox::ChatState(gloox::ChatStateActive),new gloox::Receipt(gloox::Receipt::Request,_id)
                                     
                                 });
                                    
                                    tmpMsg.addExtension(new gloox::ChatState(gloox::ChatStateActive));
                                    tmpMsg.addExtension(new gloox::Receipt(gloox::Receipt::Request,_id));
                                    std::get<0>(ss)->handleMessage(tmpMsg);
                                    break;
                                }
                            case MESSAGETYPE::REPLY: {
                                    
                                 std::get<0>(ss)->send(msg,
                                                       (std::to_string((int)type)),
                                                    {new gloox::ChatState(gloox::ChatStateActive),new gloox::Receipt(gloox::Receipt::Request,_id)
                                     
                                 });
                                    
                                    tmpMsg.addExtension(new gloox::ChatState(gloox::ChatStateActive));
                                    tmpMsg.addExtension(new gloox::Receipt(gloox::Receipt::Request,_id));
                                std::get<0>(ss)->handleMessage(tmpMsg);
                                break;
                            }
                            case MESSAGETYPE::DELETE: {
                                
                                 std::get<0>(ss)->send(msg,
                                                       (std::to_string((int)type)),
                                                    {new gloox::ChatState(gloox::ChatStateActive),new gloox::Receipt(gloox::Receipt::Request,_id)
                                     
                                 });
                                    
                                    tmpMsg.addExtension(new gloox::ChatState(gloox::ChatStateActive));
                                    tmpMsg.addExtension(new gloox::Receipt(gloox::Receipt::Request,_id));
                                    std::get<0>(ss)->handleMessage(tmpMsg);
                                break;
                            }
                            case MESSAGETYPE::RECEIPT: {
                                std::get<0>(ss)->send(msg,
                                                      (std::to_string((int)type)+" "+_id),
                                                   {new gloox::Receipt(gloox::Receipt::Received,_id)
                                    
                                });
                                   
                                 //tmpMsg.addExtension(new gloox::ChatState(gloox::ChatStateActive));
                                   tmpMsg.addExtension(new gloox::Receipt(gloox::Receipt::Received,_id));
                               
                                break;
                            }
                        }
                  
                    }
             }
               
             //if( message session not found in sessions received
                if(!found && m_delegate){
                    MessageSession*session = new MessageSession(m_client, tmpTo);
                    
                    auto chatState=new gloox::ChatStateFilter(session);
                    chatState->registerChatStateHandler(this);
                    session->registerMessageFilter(chatState);
                    session->registerMessageHandler(this);
                    m_sessions.push_back({session,nil,chatState});
                        switch(type){
                            case MESSAGETYPE::TEXT:{
                                    
                                session->send(msg,
                                                    (std::to_string((int)type)+" "+_id),
                                                    {new gloox::Receipt(gloox::Receipt::Request,_id)
                                     
                                 });
                                 
                              
                                tmpMsg.addExtension(new gloox::Receipt(gloox::Receipt::Request,_id));
                                session->handleMessage(tmpMsg);
                                break;
                            }
                            case MESSAGETYPE::FILE_ASSET_ID: {
                                
            
                                    break;
                                }
                                case MESSAGETYPE::FILE_URL: {
                                    session->send(msg,
                                                        (std::to_string((int)type)),
                                                        {//new gloox::ChatState(gloox::ChatStateActive),
                                        new gloox::Receipt(gloox::Receipt::Request,_id)
                                         
                                     });
                                    
                                    tmpMsg.addExtension(new gloox::ChatState(gloox::ChatStateActive));
                                    tmpMsg.addExtension(new gloox::Receipt(gloox::Receipt::Request,_id));
                                    session->handleMessage(tmpMsg);
                                    break;
                                }
                            case MESSAGETYPE::YOUTUBE_LINK: {
                                    
                                session->send(msg,
                                                    (std::to_string((int)type)),
                                                    {//new gloox::ChatState(gloox::ChatStateActive),
                                    new gloox::Receipt(gloox::Receipt::Request,_id)
                                     
                                 });
                                    
                                    tmpMsg.addExtension(new gloox::ChatState(gloox::ChatStateActive));
                                    tmpMsg.addExtension(new gloox::Receipt(gloox::Receipt::Request,_id));
                                    session->handleMessage(tmpMsg);
                                    break;
                                }
                            case MESSAGETYPE::REPLY: {
                                    
                                session->send(msg,
                                                    (std::to_string((int)type)),
                                                    {//new gloox::ChatState(gloox::ChatStateActive),
                                    new gloox::Receipt(gloox::Receipt::Request,_id)
                                     
                                 });
                               
                                tmpMsg.addExtension(new gloox::ChatState(gloox::ChatStateActive));
                                tmpMsg.addExtension(new gloox::Receipt(gloox::Receipt::Request,_id));
                                session->handleMessage(tmpMsg);
                                break;
                            }
                            case MESSAGETYPE::DELETE: {
                                
                                session->send(msg,
                                                    (std::to_string((int)type)),
                                                    {//new gloox::ChatState(gloox::ChatStateActive),
                                    new gloox::Receipt(gloox::Receipt::Request,_id)
                                     
                                 });
                                    
                                    tmpMsg.addExtension(new gloox::ChatState(gloox::ChatStateActive));
                                    tmpMsg.addExtension(new gloox::Receipt(gloox::Receipt::Request,_id));
                                    session->handleMessage(tmpMsg);
                                break;
                            }
                            case MESSAGETYPE::RECEIPT: {
                                session->send(msg,
                                                    (std::to_string((int)type)+" "+_id),
                                                   {new gloox::Receipt(gloox::Receipt::Received,_id)
                                });
                                   
                                   //tmpMsg.addExtension(new gloox::ChatState(gloox::ChatStateActive));
                                   //tmpMsg.addExtension(new gloox::Receipt(gloox::Receipt::Received,_id));
                                
                                break;
                            }
                        }
                    
                  //888  if(type!=MESSAGETYPE::FILE_URL && !resend)
                  //
                 //   std::cout<<"Message no session : "<<std::endl;
                    
                }
        

        // });
         
    }
    /*
void handleMessageLog( gloox::LogLevel level, gloox::LogArea area, const std::string& message ){
        
        try{
            
            
                std::string tmpLog=std::string(message);
           
            if(m_parser && std::string(tmpLog.begin()+1,tmpLog.begin()+8)=="message")
            {
                if(area==gloox::LogAreaXmlIncoming|| area== gloox::LogAreaXmlOutgoing)
                    m_parser->feed(tmpLog);
            }
                
            
            
        }catch(std::exception ex){
            
        }
     
    }
     */
    
    

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
    bool clientConnect(){
            return m_clientConnected;
    }
    
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

                  
            
           //if(m_myevent)
             //  delete  m_myevent;
            if(m_fileTransferManager)
                delete m_fileTransferManager;
            m_fileTransferManager=nullptr;
           // m_myevent=nil;
            
            if(m_sessions.size()){
                //for (auto ss: m_sessions) {
                  //  delete std::get<1>(ss);
                  //  std::get<1>(ss)=nullptr;
                  //  delete std::get<2>(ss);
                  //  std::get<2>(ss)=nullptr;
                   // m_client->disposeMessageSession(std::get<0>(ss));
                    //std::get<0>(ss)=nullptr;
                //}
                m_sessions.clear();
               
            }
            for(gloox::Bytestream *stream:m_streams)
                m_siprofilteFT->dispose(stream);
            if(m_siprofilteFT){
                delete m_siprofilteFT;
                m_siprofilteFT=nullptr;
            }
            if(m_lastActivity){
                delete m_lastActivity;
                m_lastActivity=nullptr;
            }
            
         m_clientConnected=false;
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
/*class MyMessageEvent:public gloox::LogHandler,gloox::TagHandler{
    
   
public:
    
    MyMessageEvent(gloox::Client *parent):m_client(parent),m_parser(nullptr){
       m_parser=new gloox::Parser(this,YES);
    }
    void raiseMessageEvent(gloox::JID target, gloox::MessageEventType event ,std::string _id){
        if(!m_handler)
            return;
        for (auto session : m_handler->m_sessions) {
            if(std::get<0>(session)->target().bare()==target.bare()){
                gloox::Message m(gloox::Message::Normal,target);
                gloox::MessageEvent *e=new gloox::MessageEvent(event);
                m.setID(_id);
                m.addExtension(e);
               // std::get<0>(session)->send();
            }
        }
        //gloox::Message m(gloox::Message::Normal,target);
        //gloox::MessageEvent *e=new gloox::MessageEvent(event);
        //m.setID(_id);
        //m.addExtension(e);
        //m_client->send(m);
    
    }
    void registerMessageEventHandler(XmppEgine* m){
        m_handler=m;
    }
    
   
    
    virtual void handleTag(gloox::Tag *tag){
        if(!m_handler){
            m_parser->cleanup();
            return;
        }
        
        
        if(tag->name()!="message"){
            m_parser->cleanup();
            return;
        }
        
        std::string body=std::string();
        std::string from=std::string();
        for(auto child:tag->children()){
                if(child->name()=="body")
                    body=child->cdata();
        }
        
        from=tag->findAttribute("from");
        if(body.empty()){
            gloox::TagList l=tag->children();
            auto c = l.front();
            
            if(c->findAttribute("xmlns")==gloox::XMLNS_X_EVENT){
                
                //gloox::Tag * t_td=tag->findChild("id");
                std::string msg_id=tag->findAttribute("id");
                if(!tag->findAttribute("id").size()){
                    m_parser->cleanup();
                    return;
                }
               
 
                for(auto child: c->children()){
                  
                    if(child->name()=="delivered"){
                        m_handler->handleMessageEvent(from,gloox::MessageEventDelivered,msg_id);
                    }else if(child->name()=="composing"){
                        m_handler->handleMessageEvent(from,gloox::MessageEventComposing,msg_id);
                    }
                    else if(child->name()=="displayed"){
                        m_handler->handleMessageEvent(from,gloox::MessageEventDisplayed,msg_id);
                    }
                    else if(child->name()=="offline"){
                        
                        m_handler->handleMessageEvent(from,gloox::MessageEventOffline,msg_id);
                    }
                    else if(child->name()=="cancel"){
                        m_handler->handleMessageEvent(from,gloox::MessageEventCancel,msg_id);
                    }
                }
                
            }
            
        }
        else if(!body.empty()&& from==m_handler->getMyJID().full()){
            std::cout<<"log tag\n\n\n\n"<<"\n"<<"\n\a"<<std::endl;
            gloox::Message::MessageType type=gloox::Message::Error;
            gloox::JID _to(tag->findAttribute("to"));
            gloox::JID _from(from);
            std::string _id=tag->findAttribute("id");
            if(tag->findAttribute("type")=="chat"){
                type=gloox::Message::Chat;
            }else if(tag->findAttribute("type")=="normal"){
                type=gloox::Message::Normal;
            }
            gloox::Message m(type,_to,body);
            m.setFrom(_from);
            m.setID(_id);
            m_handler->handleMessage(m,nil);
            
            
        }
     
            m_parser->cleanup();
    }
           
           
virtual void handleLog( gloox::LogLevel level, gloox::LogArea area, const std::string& message ){
        
        
        if(!m_parser)
            return;
        std::string tmpLog(message);
    if(area==gloox::LogAreaXmlIncoming){
       //using namespace std::chrono_literals;
        //std::this_thread::sleep_for(100ms);
        m_parser->feed(tmpLog);
    }
    

        
        
        
    }
    
~MyMessageEvent(){
        if( m_parser){
            delete m_parser;
        }
        m_parser=nullptr;

        m_handler=nil;
    }
private:
    gloox::Parser *m_parser;
    XmppEgine *m_handler;
    gloox::Client *m_client;
   
};

*/
#endif /* XmppEngine_hpp */

//
//  NotiMessage.hpp
//  GuysNCont
//
//  Created by SARFO KANTANKA FRIMPONG on 7/4/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#ifndef NotiMessage_hpp
#define NotiMessage_hpp


#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>
#import "gloox/client.h"
#import "gloox/message.h"
#import "gloox/messagehandler.h"
#import "gloox/eventhandler.h"
#import "gloox/loghandler.h"
#import <thread>
#include <stdio.h>
#include "gloox/connectiontls.h"
#include "gloox/connectiontcpclient.h"
#include "gloox/connectionlistener.h"
#import "gloox/messageevent.h"
#import "gloox/messagesession.h"
#import "gloox/messagesessionhandler.h"
#import "gloox/parser.h"
#import <vector>

class NotiMessage:public gloox::MessageHandler ,gloox::LogHandler,gloox::ConnectionListener,gloox::MessageSessionHandler{
    gloox::Client* m_client;
    std::pair<gloox::JID, std::string> m_userInfo;
    gloox::JID m_to;
    bool m_connected;
    std::string m_msgID;
    gloox::ConnectionTLS* m_tls;
    gloox::ConnectionTCPClient* m_tcpClient;
    gloox::Message *m_msg;
    std::vector<gloox::MessageSession*>m_msgSession;
    enum class MESSAGETYPE{TEXT=1,FILE_ASSET_ID=2,FILE_URL=3,YOUTUBE_LINK=4,REPLY=5,DELETE=6};
public:
    NotiMessage(gloox::JID to);
    
    void sendMessage(const std::string msg);
    inline void handleMessage( const gloox::Message& msg, gloox::MessageSession* session  );
    inline void handleLog( gloox::LogLevel level, gloox::LogArea area, const std::string& message );
    gloox::JID getUserJID();
    virtual void onConnect();
    virtual void onDisconnect(gloox::ConnectionError err);
    inline bool onTLSConnect(const  gloox::CertInfo& info);
    void setMessageID(NSString* _id ,NSDictionary* msg);
    void handleMessageEvent( const gloox::JID& from, gloox::MessageEventType event ,const std::string _id);
    void sendNotification(NSString* msg ,NSString* msgID,NSString* number, NSString* jid,MESSAGETYPE type);
    virtual void handleMessageSession( gloox::MessageSession* session );
};

class MyMessageEvent:public gloox::LogHandler,gloox::TagHandler{
    
    
public:
    
    MyMessageEvent(gloox::Client *parent):m_client(parent),m_parser(nullptr){
        m_parser=new gloox::Parser(this,YES);
    }
    void registerMessageEventHandler(NotiMessage* m){
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
    NotiMessage *m_handler;
    gloox::Client *m_client;
    
};

#endif /* NotiMessage_hpp */

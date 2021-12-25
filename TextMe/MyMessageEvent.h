//
//  MyMessageEvent.h
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 5/31/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#ifndef MyMessageEvent_h
#define MyMessageEvent_h
#import "XmppEgine.h"

class MyMessageEvent:public gloox::LogHandler,gloox::TagHandler{
    
    
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
                std::get<0>(session)->send(m);
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
            
        }/*else if(!body.empty()&& from==m_handler->getMyJID().full()){
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
          */
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

#endif /* MyMessageEvent_h */

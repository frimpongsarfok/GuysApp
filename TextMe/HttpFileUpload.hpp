//
//  HttpFileUpload.hpp
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 4/27/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#ifndef HttpFileUpload_hpp
#define HttpFileUpload_hpp

#include <stdio.h>
#include <gloox/stanzaextension.h>
#include <gloox/iqhandler.h>
#include "HttpFileUploadHandler.hpp"
#include <gloox/dataform.h>
#include <gloox/client.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <stdio.h>
#include <iostream>


class HttpFileUpload:public gloox::IqHandler{
    
    enum HttpContext{Capabilit=1,SlotRequest=2};
    
    class Query:public gloox::StanzaExtension{
        std::string m_filter;
        std::string m_httpXMLNS;
        std::string m_fileName;
        std::string m_fileType;
        std::string m_size;
        std::string m_id;
        gloox::JID m_to;
        //gloox::DataForm *m_dataForm;
        HttpFileUploadHandler *m_slotHandler;
        
        
    public:
        Query(gloox::JID to):gloox::StanzaExtension(gloox::ExtUser+1),
        m_filter("/iq/query/[@xmlns='http://jabber.org/protocol/disco#info']"),
        m_httpXMLNS("urn:xmpp:http:upload"),
        m_to(to){
            
        }
        Query(gloox::JID to,std::string name,std::string size,std::string type,std::string _id):gloox::StanzaExtension(gloox::ExtUser+1),
        m_filter("/iq/query/[@xmlns='http://jabber.org/protocol/disco#info']"),
        m_httpXMLNS("urn:xmpp:http:upload"),m_fileName(name),m_size(size),m_fileType(type),
        m_to(to),
        m_id(_id){
            
        }
        Query(const gloox::Tag* tag):gloox::StanzaExtension(gloox::ExtUser+1),m_filter(std::string()),m_httpXMLNS("urn:xmpp:http:upload"),m_to(gloox::JID()){
            if(tag->name()=="query" && tag->hasChild("x")){
                if(!(tag->findChild("feature")->name()==m_httpXMLNS))
                    return;
                gloox::Tag *x=tag->findChild("x");
                if(!x)
                    return;
               // m_dataForm =static_cast<gloox::DataForm*>(new gloox::DataForm(x));
                
            }else if(tag->name()=="slot"){
                
            }
            
        }
        //gloox::DataForm *severCapabilityForm(){
          //  return m_dataForm;
        //}
        virtual const std::string & filterString () const{
            
            return m_filter;
        }
        void setSlotHandler(HttpFileUploadHandler* handler){
            this->m_slotHandler=handler;
        }
        gloox::StanzaExtension* newInstance( const gloox::Tag* tag ) const
        {
            Query * tmp=new Query( tag );
            tmp->m_id=m_id;
            tmp->setSlotHandler(this->m_slotHandler);
            return tmp;
        }
        StanzaExtension* clone() const{
            
            return new Query(*this);
            
        }
        gloox::Tag* tag() const{
            
            gloox::Tag* tag=nullptr;
            if(!m_fileName.size()){
                tag=new gloox::Tag("query");
                tag->addAttribute("xmlns","http://jabber.org/protocol/disco#info");
            }else if(m_fileName.size()){
                tag=new gloox::Tag(tag,"request");
                tag->addAttribute("xmlns","urn:xmpp:http:upload:0");
                tag->addAttribute("filename", m_fileName);
                tag->addAttribute("size", m_size);
                tag->addAttribute("content-type", m_fileType);
                tag->addAttribute("id", m_id);
            }
            return tag;
        }
    };
    
    class QuerySlot:public gloox::StanzaExtension{
        
       // gloox::DataForm *m_dataForm;
        HttpFileUploadHandler *m_slotHandler;
        std::string m_fileType;
        
        
    public:
        std::string m_filter,m_getURL,m_putURL;
        QuerySlot(HttpFileUploadHandler*handler):gloox::StanzaExtension(gloox::ExtUser+2),m_filter("/iq/slot/[@xmlns='urn:xmpp:http:upload:0']"),m_getURL(""),m_putURL(""),m_slotHandler(handler){
            
        };
        
        QuerySlot(const gloox::Tag* tag):gloox::StanzaExtension(gloox::ExtUser+2),m_filter("/iq/slot/[@xmlns='urn:xmpp:http:upload:0']"),
        m_putURL(""),m_getURL(""){
           
            if(tag->name()=="slot"){
                m_getURL=tag->findChild("get")->findAttribute("url");
                m_putURL=tag->findChild("put")->findAttribute("url");
            };
            
        }
        
        virtual const std::string & filterString () const{
            
            
            return m_filter;
            
            
        }
        void setSlotHandler(HttpFileUploadHandler* handler){
            this->m_slotHandler=handler;
        }
        gloox::StanzaExtension* newInstance( const gloox::Tag* tag ) const
        {
            if(m_slotHandler){
                if(tag->name()=="slot"){
                  
                    m_slotHandler->handleSlot(tag->findAttribute("id"),tag->findChild("get")->findAttribute("url"),"",HttpFileUploadHandler::GET,m_fileType,false);
                    m_slotHandler->handleSlot(tag->findAttribute("id"),tag->findChild("put")->findAttribute("url"),"",HttpFileUploadHandler::PUT,m_fileType,false);
                    
                    
                }
            }
            
            
            return   new QuerySlot( tag );
        }
        StanzaExtension* clone() const{
            
            return new QuerySlot(*this);
            
        }
        gloox::Tag* tag() const{
            
            return nullptr;
        }
    };
    
    int m_size;
    gloox::Client *m_client;
    Query *m_query;
    std::string m_fileType;
    gloox::DataForm * m_dataForm;
    HttpFileUploadHandler *m_handler;
    gloox::JID m_to;
    std::string m_fileIdentifier,m_filePath;
     bool isResend;

public:
    HttpFileUpload(gloox::JID to,gloox::Client *client):m_client(client),m_query(nullptr),m_to(to),m_dataForm(nullptr),m_handler(nullptr),m_fileType({}),m_filePath({}),m_fileIdentifier({}),isResend(false){
        if(!m_client){
            return;
        }
        m_client->registerStanzaExtension(new Query(m_to));
        m_client->registerIqHandler(this, gloox::ExtUser+1);
       
        
        
    }
    void registerHttpFileUploadHandler(HttpFileUploadHandler* handler){
        
        m_handler=handler;
         m_client->registerStanzaExtension(new QuerySlot(m_handler));
         m_client->registerIqHandler(this, gloox::ExtUser+2);
    }
    void getServerCapability(){
        
        //if(m_dataForm)
         //   return;
        
       // gloox::IQ iq(gloox::IQ::Get,m_to);
       // iq.addExtension(new Query(m_to));
       // m_client->send(iq,this,HttpContext::Capabilit);
        
    }
    
    
    void sendFile(const std::string & path,const std::string localIdentifier,const std::string name,const std::string type,const std::string _id=std::string(),bool resend=false){
        
  /*      if(!m_dataForm){
            
            if(m_handler)
                m_handler->handleSendFileResult(HttpFileUploadHandler::HttpFileUploadResult::SvrCapNotFound);
            return;
            
            
        }*/
        m_fileIdentifier=localIdentifier;
        m_filePath=path;
        m_fileType=type;
        struct stat f_stat;
        if(stat(path.c_str(),&f_stat))
            return;
        long long size=f_stat.st_size;
        isResend=resend;
       // int severSize=std::atoi(std::string(m_dataForm->field("max-file-size")->value()).c_str());
       // if(size>severSize){
        //    if(m_handler)
        //        m_handler->handleSendFileResult(HttpFileUploadHandler::HttpFileUploadResult::FileTooLarge);
        //    return;
       // }
        std::string tmID=_id.empty()?m_client->getID():_id;
       m_handler->handleSlot(tmID,m_filePath,m_fileIdentifier,HttpFileUploadHandler::FILE_INFO,m_fileType,resend);
        gloox::IQ iq(gloox::IQ::Get,m_to);
        Query *tmpQ=new Query(m_to,name,std::to_string(size),type,tmID);
       
        tmpQ->setSlotHandler(m_handler);
        iq.addExtension(tmpQ);
        //m_handler->sendMessage(MESSAGETYPE::FILE_ASSET_ID, std::get<3>(m_fileSendingInfo),_id);
        
        m_client->send(iq,this,HttpContext::SlotRequest);
       
        
        
    }
    
    
    virtual void handleIqID( const gloox::IQ& iq, int context ){
        
        if(iq.subtype()==gloox::IQ::Result && context==HttpContext::Capabilit){
            m_query=const_cast<Query*>(iq.findExtension<Query>(gloox::ExtUser+1));
            if(!m_query)
                return;
            
            //m_dataForm=m_query->severCapabilityForm();
        }else if(iq.subtype()==gloox::IQ::Result && context==HttpContext::SlotRequest){
           // m_handler->handleSlot(iq.id(),m_filePath,m_fileIdentifier,HttpFileUploadHandler::FILE_INFO,m_fileType);
            
            
        }else if(iq.subtype()==gloox::IQ::Error && context==HttpContext::SlotRequest){
            
            if(m_handler)
                m_handler->handleSendFileResult(HttpFileUploadHandler::HttpFileUploadResult::Error);
        }
        
    }
    
    virtual bool handleIq (const gloox::IQ &iq){
        
        return true;
    }
    
  
    
};



#endif /* HttpFileUpload_hpp */

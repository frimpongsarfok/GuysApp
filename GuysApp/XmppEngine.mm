#include "XmppEngine.h"




XmppEgine::XmppEgine(id delegate,const std::string user_jid,const std::string pwd, const std::string server,bool forContactRes):
                m_myJID(gloox::JID(user_jid)),
                m_client(0),
                m_err(gloox::ConnNoError),
                m_clientConnected(false),
                m_appRunning(false),
                m_sessions({}),
                m_ipNport(std::pair< std::string,int>(std::string(),0)),
                m_presence(gloox::Presence(gloox::Presence::Unavailable,gloox::JID(),"",0)),
                m_vcardManager(nullptr),
                m_vcard(nullptr),
                m_tcpClient(nullptr),
                m_tls(nullptr),
                m_siprofilteFT(nullptr),
                m_sendingByteStreams(0),
                m_server(std::string()),
                m_sockServer(nullptr),
                m_adhocCommand(nullptr),
                m_topImage(nil),
                m_to(gloox::JID()),
                m_sockManager(nullptr),
                m_registration(nullptr),
                m_streams({}),
                m_sock5Serverlistening(nullptr),
    
                m_future(),
                m_deviceToken(""),
                m_delegate(nullptr),
                m_listeningToStreams(false),
                m_running(false),
                connectionThread(),
                m_sendFiles64data({}),
                m_parser(nullptr){
    try {
       
        m_delegate=delegate;
       // m_parser=new gloox::Parser(this,YES);
        m_client=new gloox::Client(gloox::JID(user_jid),pwd);
        m_client->setPort(5222);
       // m_client->setServer(server);
        m_client->registerConnectionListener(this);
        m_server=server;
        m_client->registerMessageSessionHandler(this,0);
        m_client->registerStanzaExtension(new gloox::ChatState(ChatStateActive));
        m_client->registerPresenceHandler(this);
        
        m_client->logInstance().registerLogHandler(gloox::LogLevelDebug, gloox::LogAreaAll, this);;
        m_privacyManager=new gloox::PrivacyManager(m_client);
        
        m_privacyManager->registerPrivacyListHandler(this);
        m_client->rosterManager()->registerRosterListener(this,true);
        m_vcardManager=new gloox::VCardManager(m_client);
        m_client->disco()->addFeature(gloox::XMLNS_CHAT_STATES);
     
        m_client->setTls(gloox::TLSRequired);
 
        registrationMode=false;
        //file
        //m_sockManager=new gloox::SOCKS5BytestreamManager(m_client->logInstance(),this);
        m_fileTransferManager=new HttpFileUpload(gloox::JID("upload."+server),m_client);
        m_fileTransferManager->registerHttpFileUploadHandler(this);
        
        
        //pubsub
        m_pubsubMang=new gloox::PubSub::Manager(m_client);
        m_client->disco()->setVersion( "GuysApp", gloox::GLOOX_VERSION, "ios" );
        m_client->disco()->setIdentity( "client", "GuysApp" );
     // m_sockServer=new gloox::SOCKS5BytestreamServer(m_client->logInstance(),5443,m_server);
       // m_sock5Serverlistening=false;
        //gloox::ConnectionError le = gloox::ConnNoError;
        //if((le=m_sockServer->listen())!=gloox::ConnNoError){
        //    //std::cout<<"listening return : "<<le<<std::endl;
        //    return;
       // }
        // m_sock5Serverlistening=true;
        //m_siprofilteFT=new gloox::SIProfileFT(m_client,this);
       // m_siprofilteFT->addStreamHost(getMyJID(), m_server,5443);
      //  m_siprofilteFT->registerSOCKS5BytestreamServer(m_sockServer);
       // m_siprofilteFT->registerSIProfileFTHandler(this);
       // m_listeningToStreams=false;
        m_lastActivityManager=new MyLastActivity(m_client);
        m_lastActivityManager->resetIdleTimer();
        m_lastActivityManager->registerLastActivityHandler(this);
        connect();
 
        } catch (const std::exception& e) {
            //std::cout<<"Xmpp Error : "<<e.what()<<std::endl;
        }
               
                    
                

}


bool XmppEgine::connect(){
    
   
        try {
           // @autoreleasepool{
           //char queueName[]="connectQueue";

           // dispatch_queue_t t=dispatch_queue_create(queueName, NULL);
            
            //dispatch_async(t, ^{
                
           
           //std::thread t([this](gloox::Client *client){
            
            
                char queueName[]="connectQueue";
                m_connectThread=dispatch_queue_create(queueName, NULL);
                //dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_async(m_connectThread, ^{
                try {
                    if(!m_client->connect(false))
                                 return;
                     gloox::ConnectionError ce=gloox::ConnNoError;
                      m_appRunning=true;
                      while (ce==gloox::ConnNoError) {
                          
                          if(m_appRunning){
                              ce=m_client->recv(100);
                              
                          }else {
                              ce=gloox::ConnUserDisconnected;
                              m_client->disconnect();
                              //std::this_thread::sleep_for(std::chrono::seconds(1));
                              
                          }
                          
                         if(ce!=gloox::ConnNoError ){
                              if (ce==gloox::ConnectionError::ConnUserDisconnected){
                                   //std::cout<<"disconnect "<<ce<<std::endl;
                                break;
                              }

                          //std::cout<<" client  fail to recv data from server"<<std::endl;
                          break;

                        }
                      }
                    
                }catch (std::exception ex) {
                    //std::cout<<"Connection Errr:"<<std::endl;
                       // //std::cout<<"Connection Exception Occured :"<<ex.what()<<std::endl;
                }
            });
                
            //std::thread([this]{
                
            //}).detach();
                 
               // });
//                    try {
//                        if(!m_client)
//                             return false;
//                         if(!m_client->connect(false))
//                             return false;
//                         gloox::ConnectionError ce=gloox::ConnNoError;
//                          while (ce==gloox::ConnNoError ) {
//                              ce=m_client->recv(00);
//                             if(ce!=gloox::ConnNoError ){
//                                  if (ce==gloox::ConnectionError::ConnUserDisconnected){
//                                       //std::cout<<"disconnect "<<ce<<std::endl;
//                                    break;
//                                  }
//
//                              //std::cout<<" client  fail to recv data from server"<<std::endl;
//                              break;
//
//                          }
//                        }
//                    }catch(std::exception ex ){
//                        //std::cout<<"connection stream errr : "<<ex.what()<<std::endl;
//                    }
             
                
             //if(m_sockServer){
             //   se=m_sockServer->recv(1);
             //   if(se!=gloox::ConnNoError){
            //        //std::cout<<" sock5  fail to recv data from server ,return :"<<se<<std::endl;
             //         break;
             // delete m_sockServer;
             // m_sockServer=nullptr;
             //    }
            
             return true;
       // }).detach();
              //  });
            //}
    } catch (NSException* ex) {
        NSLog(@"Connection Errr: %@",[ex reason]);
       // //std::cout<<"Connection Exception Occured :"<<ex.what()<<std::endl;
        return false;
    }
    
    
    //t.join();
    //listing to incoming file;
    return true;
}

void XmppEgine::handleSendFileResult(HttpFileUploadHandler::HttpFileUploadResult result){

    
}


void XmppEgine::handleSlot(const std::string _id,const std::string slot,const std::string fileID,SLOTTYPE type,const std::string filetype,bool resend){
    
    switch (type) {
           
        case HttpFileUploadHandler::FILE_INFO:{
            //std::cout<<"FILE_INFO :"<<slot<<std::endl;
            //const gloox::Message m(gloox::Message::Chat,getToJID(),url,std::to_string(type));
            //s
            std::get<0>(m_fileSendingInfo)=slot;
             std::get<3>(m_fileSendingInfo)=fileID;
              std::get<4>(m_fileSendingInfo)=_id;
            
            
              if(m_delegate && !resend)
                  [m_delegate handleSlotForPathOnly:[NSString stringWithUTF8String:_id.c_str()] filePath:[NSString stringWithUTF8String:slot.c_str()] fileIdentifier:[NSString stringWithUTF8String:fileID.c_str()] fileType:[NSString stringWithUTF8String:filetype.c_str()]];
            
        }
            break;
        case HttpFileUploadHandler::GET:{
          
           
            //std::cout<<"GET URL :"<<slot<<std::endl;
           // const gloox::Message m(gloox::Message::Chat,getToJID(),url,std::to_string(type));
            std::get<1>(m_fileSendingInfo)=slot;
            
            
        }
            break;
        case HttpFileUploadHandler::PUT:{
            std::get<2>(m_fileSendingInfo)=slot;
            //std::cout<<"PUT URL :"<<slot<<std::endl;
            
            
           
        }
          
            break;
        default:
            break;
    }
    if(std::get<0>(m_fileSendingInfo).size() && std::get<1>(m_fileSendingInfo).size() && std::get<2>(m_fileSendingInfo).size()){
        
        
      
        if(m_delegate){
          [ m_delegate handleSlot:[NSString stringWithUTF8String:std::get<4>(m_fileSendingInfo).c_str()]
                       fileGetUrl:[NSString stringWithUTF8String:std::get<1>(m_fileSendingInfo).c_str()]
                       filePutUrl: [NSString stringWithUTF8String:std::get<2>(m_fileSendingInfo).c_str()]
                       filePath:[NSString stringWithUTF8String:std::get<0>(m_fileSendingInfo).c_str()]
                       fileIdentifier:[NSString stringWithUTF8String:std::get<3>(m_fileSendingInfo).c_str()]
                       fileType:[NSString stringWithUTF8String:filetype.c_str()]];
        m_fileSendingInfo={};
         
        }
    }
   
   
}


bool XmppEgine::handleIq(const gloox::IQ &iq){
    ////std::cout<<"iq  "<<iq.from().bare()<<std::endl;
    return true;
}
void XmppEgine::handleIqID (const gloox::IQ &iq, int context){
    
}
inline void XmppEgine::setIpNPort(const std::string& message){
    try {
        
        std::size_t tmp1=message.find("(");
        std::size_t tmp2=message.find(":");
        std::size_t tmp3=message.find(")");
        std::string ip=message.substr(tmp1+1,tmp2-tmp1-1);
        int port=std::stoi(message.substr(tmp2+1,tmp3-tmp2-1));
        std::pair<std::string, int> data=std::pair(ip,port);
        m_ipNport.swap(data);
    } catch (std::exception e) {
        e.what();
    }

}


inline void XmppEgine::onConnect(){
    m_clientConnected=true;
    //std::cout<<"connect : "<<std::endl;
    if(m_delegate)
       [m_delegate connected];
    
   
    
    
}
inline void XmppEgine::onDisconnect(gloox::ConnectionError e){
        
            m_clientConnected=false;
            //std::cout<<"disconnected : "<<e<<std::endl;
            m_listeningToStreams=false;
            m_client=nullptr;
            m_appRunning=false;
            try {
               
                if([NSThread isMainThread]){
                    [m_delegate onDisconnect:e];
                }else{
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [m_delegate onDisconnect:e];
                    });
                }
                
            }catch (NSException* objtc_exp) {
                   NSLog(@"%@",objtc_exp);
                   
            }

    

    
}
inline bool XmppEgine::onTLSConnect(const  gloox::CertInfo& info){

    return true;
}

//vcard
void XmppEgine::handleVCard(const gloox::JID& jid,const gloox::VCard* vcard){
   
        if(jid.bare()==getMyJID().bare() && m_delegate){
             m_vcard=const_cast<gloox::VCard*> (vcard); 
            if(m_delegate)
                dispatch_sync(dispatch_get_main_queue(), ^{
                     [m_delegate handleSelfVCard:vcard];
                    
                });
            
     
        }else{
            if(m_delegate)
                dispatch_sync(dispatch_get_main_queue(), ^{
                          [m_delegate handleVCard:jid Card:vcard];
                        
                    });
        }
   

}
void XmppEgine::handleVCardResult (VCardContext context, const gloox::JID &jid, gloox::StanzaError se){
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        if(!m_delegate)
            return;
        if(jid.bare()==m_client->jid().bare()){
            if(context==VCardContext::FetchVCard){
                [m_delegate handleSelfFetchVCardResult:se ];
                
            }else{
                 [m_delegate handleSelfStoreVCardResult:se ];
               
            }
        }else{
            [m_delegate handleFetchVCardResult:jid StanzaErr:se];
            
            
        }
    });

}
//roster
inline void XmppEgine::refreshRoster(){
    if(m_client)
    m_client->rosterManager()->fill();
   
}

inline void XmppEgine::handleItemAdded( const gloox::JID& jid ){
    
   // dispatch_async(dispatch_get_main_queue(), ^{
        if(m_delegate)
            [m_delegate handleItemAdded:jid];

    //});
}
inline void XmppEgine::handleItemSubscribed( const gloox::JID& jid ){
    
    dispatch_async(dispatch_get_main_queue(), ^{
    if(m_delegate)
        [m_delegate handleItemSubscribed:jid];
        
    });
    
    
}
inline void XmppEgine:: handleItemRemoved( const gloox::JID& jid ){
    
        dispatch_sync(dispatch_get_main_queue(), ^{
            if(m_delegate)
                [m_delegate  handleItemRemoved:jid];
        });

}
inline void XmppEgine:: handleItemUpdated( const gloox::JID& jid ){
    
        dispatch_sync(dispatch_get_main_queue(), ^{
            if(m_delegate)
                [m_delegate  handleItemUpdated:jid];
        });
}
inline void XmppEgine::handleItemUnsubscribed( const gloox::JID& jid ){
    if(m_delegate)
        [m_delegate  handleItemUnsubscribed:jid];
}
inline void XmppEgine::handleRoster( const gloox::Roster& roster ){
    if(!clientIsconnected())
        return;
//    std::thread([this,roster]{
//        m_lastActivityManager->resetIdleTimer();
//            for(auto ros:roster){
//                if(!m_clientConnected)
//                    return;
//                  m_lastActivityManager->query(gloox::JID(ros.first));
//                  std::this_thread::sleep_for(std::chrono::milliseconds(100));
//                
//            }
//    }).detach();
//    

        
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        if(m_delegate)
            [m_delegate handleRoster:roster];
        //std::cout<<"\t rosterss \trjrjrrj"<<roster.size()<<std::endl;
    });

}
inline void XmppEgine::handleRosterError( const gloox::IQ& iq) {
    
}
inline void XmppEgine::handleRosterPresence( const gloox::RosterItem& item, const std::string& resource,
                                            gloox::Presence::PresenceType presence, const std::string& msg ){

    dispatch_sync(dispatch_get_main_queue(), ^{
        if(m_delegate)
            //m_client->rosterManager()->roster();
          [m_delegate handleRosterPresence:item resource:resource presence:presence message:msg];
        
    });

}


inline void XmppEgine::handleSelfPresence( const gloox::RosterItem& item, const std::string& resource,gloox::Presence::PresenceType presence, const std::string& msg ){
    dispatch_sync(dispatch_get_main_queue(), ^{
        //std::cout<<"self presence"<<presence<<": " <<msg <<std::endl;
        if(m_delegate)
            [m_delegate  hanldeSelfPresence:item resource:resource presence:presence message:msg];
    });
    
}

inline bool XmppEgine::handleSubscriptionRequest( const gloox::JID& jid, const std::string& msg ){
    
    
    this->m_client->rosterManager()->subscribe(jid);
    this->fetchVCard(jid);
    return true;
}
inline bool XmppEgine::handleUnsubscriptionRequest( const gloox::JID& jid, const std::string& msg ){
  
    dispatch_sync(dispatch_get_main_queue(), ^{
        if(m_delegate)
            [m_delegate handleUnsubscriptionRequest:jid message:msg];
    });
    return true;
}
inline void XmppEgine::handleNonrosterPresence( const gloox::Presence& presence ){
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        if(m_delegate)
            [m_delegate handleNonrosterPresence:presence];
    });
   
}

inline void XmppEgine::handleMessageSession( gloox::MessageSession* session ) {
    
    

    bool found=false;
    for (auto tt: m_sessions) {
        if(std::get<0>(tt)->target().bare()==session->target().bare()){
            found=true;
            auto chatState=new gloox::ChatStateFilter(session);
            chatState->registerChatStateHandler(this);
            session->registerMessageHandler(this);
            m_client->registerMessageSession(session);
            tt={session,nil,chatState};
            break;;
        }
    }
    if(!found){
        
        auto chatState=new gloox::ChatStateFilter(session);
        chatState->registerChatStateHandler(this);
        session->registerMessageHandler(this);
        m_client->registerMessageSession(session);
        m_sessions.push_back({session,nil,chatState});
    }
        

   
    
   
    


}

void XmppEgine::createMessageSesstion(const gloox::JID jid){
    
}
//messages


//using taghandle because  gloox::handlemessage  out msg does not include id;
inline void XmppEgine::handleTag(    gloox::Tag *     tag    ){
    //std::cout<<"tag message called"<<std::endl;
//
//    if(!m_parser)
//        return;
//    if(tag->name()!="message"){
//        m_parser->cleanup();
//        return;
//    }
//    std::string body=std::string();
//    std::string from=std::string();
//    std::string to=std::string();
//    std::string _id=std::string();
//    std::string threadid=std::string();
//    std::string subject=std::string();
//    gloox::Message::MessageType type=gloox::Message::Chat;
//    for (gloox::Tag::Attribute* att:tag->attributes()) {
//                if(att->name()=="id")
//                    _id=att->value();
//                if(att->name()=="from")
//                    from=att->value();
//                if(att->name()=="to")
//                    to=att->value();
//
//
//    }
//
//    for(auto child:tag->children()){
//        if(child->name()=="body")
//            body =child->cdata();
//        if(child->name()=="thread")
//            threadid =child->cdata();
//        if(child->name()=="subject")
//            subject=child->cdata();
//        if(child->name()=="type")
//            type=(gloox::Message::MessageType)atoi(child->cdata().c_str());
//
//
//
//    }
//    gloox::Message msg=gloox::Message (type, gloox::JID(to), body,subject, threadid);
//    msg.setID(_id);
//    msg.setFrom(gloox::JID(from));
//    for(auto ext:msg.extensions())
//        msg.addExtension(ext);
//
//    bool found=NO;
//    for (auto ss: m_sessions) {
//
//        if(std::get<0>(ss)->target()==m_to ){
//            found=YES;
//
//           //handleMessage(msg,(gloox::MessageSession*)std::get<0>(ss));
//            return;
//        }
//
//    }
//    if(!found){
//        gloox::MessageSession *ss= new gloox::MessageSession(m_client,gloox::JID(to));
//        ss->registerMessageHandler(this);
//       // myHandleMessage(msg,ss);
//        m_sessions.push_back({ss,nil,nil});
//    }
//
//    m_parser->cleanup();
}
inline void XmppEgine::handleMessage( const gloox::Message& msg, gloox::MessageSession* session  ){
  
    
    
         //chatsate messages
    
        gloox::JID jid=gloox::JID();
        if(msg.from().bare()!=getMyJID().bare()){
            jid=msg.from();
        }else if (msg.to().bare()!=getMyJID().bare()){
            jid=msg.to();
        }
         addPartnerToRoster(jid);
    
    if([NSThread isMainThread]){
        if(m_delegate)
            [m_delegate handleMessage:msg session:session];
            //std::cout<<"session handling"<<std::endl;
        
    }else{
        dispatch_sync(dispatch_get_main_queue(), ^{
           
            if(m_delegate)
                [m_delegate handleMessage:msg session:session];
            
       
        });
    }
    
    
}
inline void XmppEgine::handleChatState( const gloox:: JID& from,gloox:: ChatStateType state ){

    //std::cout<<"chatssssssssssssssssss evvvvveeennt"<<std::endl;
    dispatch_sync(dispatch_get_main_queue(), ^{
        if(m_delegate)
            [m_delegate handleChatState:from state:state];
    });
}

//presence
inline void XmppEgine::handlePresence( const gloox::Presence& presence ){
   
   
    if(presence.from()==getMyJID() ){
        if(presence.presence()==gloox::Presence::PresenceType::Available){
            m_privacyManager->requestListNames();
            m_fileTransferManager->getServerCapability();
        }
   
        m_presence=gloox::Presence(presence.subtype(),presence.to(),presence.status(),presence.presence());
        
        
    }
    dispatch_sync(dispatch_get_main_queue(), ^{
   // gloox::Presence p=const_cast<gloox::Presence>(**presence);
    //std::thread t([this,pre]{
        

    if(m_delegate){
              // //std::cout<<"presence from : "<<pre.from().full()<<" "<<pre.presence()<<" "<<pre.tag()->xml()<<std::endl;
           [m_delegate handlePresence:presence];
        }
        
    });
//    if(presence.presence()!=gloox::Presence::Available){
//
//        for(auto ss=m_sessions.begin();ss!=m_sessions.end();++ss){
//            if( std::get<0>(*ss)){
//                if(std::get<0>(*ss)->target().bare()==presence.from().bare()){
//                    //m_client->di
//                    std::get<0>(*ss)->disposeMessageFilter(std::get<2>(*ss));
//                    m_client->disposeMessageSession(std::get<0>(*ss));
//                    m_sessions.erase(ss);
//                    break;
//
//                }
//            }else{
//                m_sessions.erase(ss);
//            }
//        }
//    }
    //t.detach();
       
//});
  
}
inline void XmppEgine::handleLog( gloox::LogLevel level, gloox::LogArea area, const std::string& message ){

   // dispatch_sync(dispatch_get_main_queue(), ^{
    if(m_delegate){
            [m_delegate handleLog:[NSString stringWithUTF8String:message.c_str()]];
            //  handleMessageLog(level, area, std::string(message));
    }
   // });
    
    
    if(area==32){
        setIpNPort(message);
    }
  
}


//Account registration
XmppEgine::XmppEgine(id delegate,const std::string& server):
                                                    m_myJID(gloox::JID()),
                                                    m_client(0),
                                                    m_err(gloox::ConnNoError),
                                                    m_clientConnected(false),
                                                    m_appRunning(false),
                                                    m_sessions({}),
                                                    m_ipNport(std::pair< std::string,int>(std::string(),0)),
                                                    m_presence(gloox::Presence(gloox::Presence::Unavailable,gloox::JID(),"",0)),
                                                    m_vcardManager(nullptr),
                                                    m_vcard(nullptr),
                                                    m_tcpClient(nullptr),
                                                    m_tls(nullptr),
                                                    m_siprofilteFT(nullptr),
                                                    m_sendingByteStreams(0),
                                                    m_server(std::string()),
                                                    m_sockServer(nullptr),
                                                    m_adhocCommand(nullptr),
                                                    m_topImage(nil),
                                                    m_sockManager(nullptr),
                                                    m_registration(nullptr),
                                                    m_to(gloox::JID()),
                                                    m_streams({}),
                                                    m_sock5Serverlistening(nullptr),
                                                    m_future(),
                                                    m_deviceToken(""),
                                                    m_delegate(nullptr),
                                                    m_listeningToStreams(false),
                                                    m_running(false),
                                                   m_lastActivityManager(nullptr),
                                                
                                                    m_parser(nullptr){
    try {
        m_delegate=delegate;
        m_client=new gloox::Client(server);
        m_server=server;
        m_client->disableRoster();
        m_client->registerConnectionListener(this);
        m_client->logInstance().registerLogHandler(gloox::LogLevelDebug, gloox::LogAreaAll, this);
        m_client->setPort(5222);
        m_client->setServer(m_server);
        m_registration=new gloox::Registration(m_client);
        m_registration->registerRegistrationHandler(this);
        m_fileTransferManager=nullptr;
        registrationMode=true;
        m_listeningToStreams=false;
        m_parser=nullptr;
        connect();
    } catch (std::exception err) {
        //std::cout<<" c++ registration error occured in registration :"<<err.what()<<std::endl;
       
    }catch(NSException *objcErr){
        NSLog(@"%@",[objcErr description]);
    }

}

void XmppEgine::handleRegistrationResult(const gloox::JID& from ,gloox::RegistrationResult result){
     dispatch_sync(dispatch_get_main_queue(), ^{
         //std::cout<<"registration result :"<<result<<std::endl;
        if(m_delegate)//{
            [m_delegate handleRegistrationResult:from registreationResult:result];
     });
}
void XmppEgine::handleRegistrationFields(const gloox::JID& jid,int fiedls, std::string instruction){
    //std::cout<<"registration feilds :"<<fiedls<<" : instruction :"<<instruction<<std::endl;
    if(m_delegate)
      [ m_delegate handleRegistrationFields:jid Fields:fiedls Instruction:instruction];
}
void XmppEgine::handleDataForm(const gloox::JID& jid,const gloox::DataForm& data){
    //std::cout<<"this is dataformmm"<<std::endl;
    if(m_delegate)
        [m_delegate handleDataForm:jid dataForm:data];
}
void XmppEgine::handleOOB(const gloox::JID& jid,const gloox::OOB& oob){
    if(m_delegate)
        [m_delegate handleOOB:jid OOB:oob];
}
void XmppEgine::handleAlreadyRegistered(const gloox::JID& from){
    
    if(m_delegate)
        [m_delegate handleAlreadyRegistered:from];
        //std::cout<<"account already exist"<<std::endl;
}

void XmppEgine::registerAccount(const std::string userName,const std::string password){
    try {
        gloox::RegistrationFields fields;
        fields.username=userName;
        fields.password=password;
        //std::cout<<"user name and pwd :"<<userName<<"\t"<<password<<std::endl;
        //gloox::DataForm *userForm=new gloox::DataForm(gloox::TypeSubmit);
       //userForm->setTitle("Creating a new account");
       //userForm->addField(gloox::DataFormField::TypeTextSingle,"username",userName,"Username");
       // userForm->addField(gloox::DataFormField::TypeTextPrivate,"password",password,"Password");
        
        m_registration->createAccount(5,fields);
    } catch (std::exception ex) {
        //std::cout<<ex.what()<<std::endl;
    }
    
  
}
bool XmppEgine::deleteAccount(){
    try {
        if(clientIsconnected()){
            if(!m_registration){
                m_registration=new gloox::Registration(m_client);
                m_registration->registerRegistrationHandler(this);
                registrationMode=true;
                m_listeningToStreams=false;
                for(auto part:*m_client->rosterManager()->roster()){
                    if(!m_clientConnected)
                        return false;
                    m_client->rosterManager()->cancel(gloox::JID(part.first));
                    std::this_thread::sleep_for(std::chrono::milliseconds(100));
                }
                m_registration->removeAccount();
                return true;
            }
            
           
            
        }
       
    } catch (std::exception ex) {
        //std::cout<<ex.what()<<std::endl;
    }
    return false;
}
void XmppEgine::fetchFields(){
    m_registration->fetchRegistrationFields();
    
}
void XmppEgine::registerDeviceToken(std::string token){
    if(!getMyJID().bare().size() && m_clientConnected){
        //std::cout<<"Error Cant register device, my JID is empty"<<getMyJID().bare()<<std::endl;
        return;
    }
    std::async(std::launch::async, [this,&token](){
        using namespace std::chrono_literals;
       
        //registerIQ->set
        m_adhocCommand=new gloox::Adhoc(m_client);
        m_adhocCommand->registerAdhocCommandProvider(this, "registerPush", "Register APNS Notification");
        gloox::DataForm *data=new gloox::DataForm(gloox::FormType::TypeSubmit);
        gloox::DataFormField *field=new gloox::DataFormField("token",token,"",gloox::DataFormField::FieldType::TypeTextMulti);
        data->addField(field);
        gloox::Adhoc::Command *cmd=new gloox::Adhoc::Command("register-push-apns","--",gloox::Adhoc::Command::Action::Execute,data);
       
        
        m_adhocCommand->execute(getMyJID(),cmd, this);
        //gloox::IQ *iq=new gloox::IQ(gloox::IQ::Set,m_client->jid().server());
        //iq->addExtension(cmd);
        //m_client->send(*iq);
        ////std::cout<<"/////// "<<m_adhocCommand->tag()->xml()<<std::endl;
        
    });

    
    
    
}
void    XmppEgine::handleAdhocCommand (const gloox::JID &from, const gloox::Adhoc::Command &command, const std::string &sessionID){
    //std::cout<<"adhoc command received"<<std::endl;
}

bool   XmppEgine::handleAdhocAccessRequest (const gloox::JID &from, const std::string &command){
     //std::cout<<"adhoc command request "<< command<<std::endl;
    return true;
}
void   XmppEgine::  handleAdhocSupport (const gloox::JID &remote, bool support, int context){
     //std::cout<<"adhoc support"<<std::endl;
}

void    XmppEgine:: handleAdhocCommands (const gloox::JID &remote, const gloox::StringMap &commands, int context){
     //std::cout<<"adhoc command "<<std::endl;
}

void     XmppEgine::handleAdhocError (const gloox::JID &remote, const gloox::Error *error, int context){
    //std::cout<<"adhoc command erro : "<< context<<std::endl;
}

void      XmppEgine::handleAdhocExecutionResult (const gloox::JID &remote, const gloox::Adhoc::Command &command, int context){
     //std::cout<<"adhoc resul "<<std::endl;
}


void XmppEgine::handleFTRequestResult( const gloox::JID& from, const std::string& sid )
{
    
   
    printf( "ft request result %s\n",sid.c_str() );
}

void XmppEgine::handleFTRequestError( const gloox::IQ& /*iq*/, const std::string& sid )
{
    printf( "ft request error\n" );
   
}
void XmppEgine::handleFTRequest( const gloox::JID& from, const gloox::JID& to, const std::string& sid,
                             const std::string& name, long size, const std::string& hash,
                             const std::string& date, const std::string& mimetype,
                             const std::string& desc, int stypes )
{
    printf( "received ft request from %s: %s (%ld bytes, sid: %s). hash: %s, date: %s, mime-type: %s\n"
           "desc: %s\n",
           from.full().c_str(), name.c_str(), size, sid.c_str(), hash.c_str(), date.c_str(),
           mimetype.c_str(), desc.c_str() );
    m_siprofilteFT->acceptFT( from, sid, gloox::SIProfileFT::FTTypeIBB );
}
void XmppEgine::handleFTBytestream( gloox::Bytestream* bs )
{
    
      printf( "received bytestream of typess: %s", bs->type() == gloox::Bytestream::S5B ? bs->target().bare().c_str() : bs->target().bare().c_str() );
   
    
      //std::thread t([this,bs](){
        bs->registerBytestreamDataHandler( this );

        if( bs->connect() )
        {
            if( bs->type() == gloox::Bytestream::S5B )
                printf( "ok! s5b connected to streamhost\n" );
            else
                printf( "ok! ibb sent request to remote entity\n" );
        }
         if(bs->initiator().bare()==getMyJID().bare()){
            bs->recv(100);
           
         }else{
             for (auto data : m_sendFiles64data) {
                 for (std::string bytes : data) {
                     bs->send(bytes);
                 }
             }
             bs->close();
             
         }
    //});
  ///  t.detach();
    

}

const std::string XmppEgine::handleOOBRequestResult( const gloox::JID& /*from*/, const gloox::JID& /*to*/, const std::string& /*sid*/ )
{
    return std::string();
};

void XmppEgine::handleBytestreamData( gloox::Bytestream* bs, const std::string& data )
{
    if(bs->isOpen()){
         printf( "received %lu bytes of data:\n%s\n", data.length(), data.c_str() );
        
    }
   
}

void XmppEgine::handleBytestreamError( gloox::Bytestream* /*bs*/, const gloox::IQ& /*iq*/ )
{
    printf( "bytestream error\n" );
}

void XmppEgine::handleBytestreamOpen( gloox::Bytestream* /*bs*/ )
{
    printf( "bytestream opened\n" );
}

void XmppEgine::handleBytestreamClose( gloox::Bytestream* bs )
{
    printf( "bytestream closed\n" );
    

}
void    XmppEgine::handlePrivacyListNames (const std::string &active, const std::string &def, const gloox::StringList &lists){
    if(m_delegate)
       [m_delegate handlePrivacyListNames:active def:def privacyList:lists];
}

void  XmppEgine::handlePrivacyList (const std::string &name, const PrivacyList &items){
     if(m_delegate)
    [m_delegate handlePrivacyList:name privacyList:items];
}

void    XmppEgine::handlePrivacyListChanged (const std::string &name){
     if(m_delegate)
    [m_delegate handlePrivacyListChanged:name];
}

void   XmppEgine::handlePrivacyListResult (const std::string &_id, gloox::PrivacyListResult plResult){
    if(m_delegate)
        [m_delegate handlePrivacyListResult:_id result:plResult];
}
void XmppEgine:: handleLastActivityResult( const gloox::JID& jid, long seconds, const std::string& status ) {
    dispatch_sync(dispatch_get_main_queue(), ^{
        if(m_delegate)
            [m_delegate handleLastActivityResult:jid timeInSec:seconds statusMsg:status];
    });
}
void XmppEgine:: handleLastActivityError( const   gloox::JID& jid, gloox::StanzaError error ) {
    dispatch_sync(dispatch_get_main_queue(), ^{
      if(m_delegate)
          [m_delegate handleLastActivityError:jid errorMsg:error];
    });
    
}
//pubsub


   
void   XmppEgine::handleItem (const gloox::JID &service, const std::string &node, const gloox::Tag *entry){
    //std::cout<<"handleItem *** "<<node<<std::endl;
}
   
void      XmppEgine::handleItems (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::PubSub::ItemList &itemList, const gloox::Error *error){
    //std::cout<<"handleItems *** "<<node<<std::endl;
}
   
void      XmppEgine::handleItemPublication (const std::string &id, const gloox::JID &service, const std::string &node ,const gloox::PubSub::ItemList &itemList, const gloox::Error *error){
    //std::cout<<"handleItemPublication *** "<<node<<std::endl;
}
void     XmppEgine::handleItemDeletion (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::PubSub::ItemList &itemListclass , const class gloox::Error *error){
    //std::cout<<"handleItemDeletion *** "<<node<<std::endl;
}
void      XmppEgine::handleSubscriptionResult( const std::string& id, const gloox::JID& service,const std::string& node,const std::string& sid,const gloox::JID& jid,const gloox::PubSub::SubscriptionType subType,const gloox::Error* error  ){
     //std::cout<<"handleSubscriptionResult *** "<<node<<std::endl;
}


   
void      XmppEgine::handleUnsubscriptionResult (const std::string &id, const gloox::JID &service, const gloox::Error *error){
    //std::cout<<"handleUnsubscriptionResult *** "<<service.full()<<std::endl;
}
   
void      XmppEgine::handleSubscriptionOptions (const std::string &id, const gloox::JID &service, const gloox::JID &jid, const std::string &node, const gloox::DataForm *options, const std::string &sid, const gloox::Error *error){
    //std::cout<<"handleSubscriptionOptions *** "<<node<<std::endl;
}
   
void     XmppEgine::handleSubscriptionOptionsResult (const std::string &id, const gloox::JID &service, const gloox::JID &jid, const std::string &node, const std::string &sid, const gloox::Error *error){
    //std::cout<<"handleSubscriptionOptionsResult *** "<<node<<std::endl;
}
   
 void     XmppEgine::handleSubscribers (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::PubSub::SubscriptionList &list, const gloox::Error *error){
     //std::cout<<"handleSubscribers *** "<<node<<std::endl;
}
   
 void    XmppEgine:: handleSubscribersResult (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::PubSub::SubscriberList *list, const gloox::Error *error){
     //std::cout<<"handleSubscribersResult *** "<<node<<std::endl;

}
   
 void    XmppEgine:: handleAffiliates (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::PubSub::AffiliateList *list, const gloox::Error *error){
     //std::cout<<"handleAffiliates *** "<<node<<std::endl;
}
   
void     XmppEgine::handleAffiliatesResult (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::PubSub::AffiliateList *list, const gloox::Error *error){
    //std::cout<<"handleAffiliatesResult *** "<<node<<std::endl;
}
   
void     XmppEgine::handleNodeConfig (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::DataForm *config, const gloox::Error *error){
    //std::cout<<"handleNodeConfig *** "<<node<<std::endl;
}
   
void     XmppEgine::handleNodeConfigResult (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::Error *error){
    //std::cout<<"handleNodeConfigResult *** "<<node<<std::endl;
}
   
void     XmppEgine::handleNodeCreation (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::Error *error){
    //std::cout<<"handleNodeCreation *** "<<node<<std::endl;
}
   
void     XmppEgine::handleNodeDeletion (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::Error *error){
    //std::cout<<"handleNodeDeletion *** "<<node<<std::endl;
}
   
 void     XmppEgine::handleNodePurge (const std::string &id, const gloox::JID &service, const std::string &node, const gloox::Error *error){
     //std::cout<<"handleNodePurge *** "<<node<<std::endl;
}

 void     XmppEgine::handleSubscriptions (const std::string &id, const gloox::JID &service, const gloox::PubSub::SubscriptionMap &subMap, const gloox::Error *error){
     //std::cout<<"handleSubscriptions *** "<<service.full()<<std::endl;
}
   
void     XmppEgine::handleAffiliations (const std::string &id, const gloox::JID &service, const gloox::PubSub::AffiliationMap &affMap, const gloox::Error *error){
    //std::cout<<"handleAffiliations *** "<<service.full()<<std::endl;
}
void     XmppEgine::handleDefaultNodeConfig (const std::string &id, const gloox::JID &service, const gloox::DataForm *config, const gloox::Error *error){
    //std::cout<<"handleDefaultNodeConfig *** "<<service.full()<<std::endl;
}
   

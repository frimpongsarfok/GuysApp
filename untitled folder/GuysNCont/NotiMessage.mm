//
//  NotiMessage.cpp
//  GuysNCont
//
//  Created by SARFO KANTANKA FRIMPONG on 7/4/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#include "NotiMessage.hpp"
NotiMessage::NotiMessage(gloox::JID to ):m_to(to),m_userInfo({}),m_client(nullptr),m_msgSession({}){
    
    m_userInfo={getUserJID(),getUserJID().username()};
    if(m_userInfo.second.empty())
        return;
    m_client=new gloox::Client(m_userInfo.first,m_userInfo.second);
    m_client->disableRoster();
    m_client->registerMessageHandler(this);
    m_client->logInstance().registerLogHandler(gloox::LogLevelDebug, gloox::LogAreaAll, this);
    m_client->registerConnectionListener(this);
    m_client->registerMessageSessionHandler(this);
    
    dispatch_queue_t t=dispatch_queue_create("Noti", NULL);
    dispatch_async(t, ^{
         m_client->connect();
    });
    (new MyMessageEvent(m_client))->registerMessageEventHandler(this);
    
}
void NotiMessage::sendMessage(const std::string msg){
    if(m_userInfo.second.empty())
        return;
    
    m_msgID=m_client->getID();
    m_msg=new gloox::Message(gloox::Message::Chat,m_to,msg,std::to_string(1)/*MESSAGETYPE::TEXT /user can past youtube link -need future update/*/);
    m_msg->setFrom(m_userInfo.first);
    m_msg->setID(m_msgID);
    m_msg->addExtension(new gloox::MessageEvent(gloox::MessageEventComposing|gloox::MessageEventDelivered|gloox::MessageEventDisplayed|gloox::MessageEventOffline));
    handleMessage(*m_msg, nullptr);
    
}

void NotiMessage::onConnect(){
    
    //for (auto itr : m_msgSession) {
     //   if(itr->target().bare()==m_msg->to().bare()){
     //       itr->send(*m_msg);
      //      itr->sen
    //    }
   // }else{
         m_client->send(*m_msg);
    //h}
   
    handleMessageEvent(m_msg->from(), gloox::MessageEventDelivered, m_msg->id());
    using namespace std::chrono_literals;
    std::this_thread::sleep_for(2s);
    
    m_client->disconnect();
}
 void NotiMessage::onDisconnect(gloox::ConnectionError err){
     if(m_client){
        // delete m_client;
       //  m_client=nullptr;
     }
     if(m_msg){
         //delete m_msg;
         //m_msg=nullptr;
     }
}
inline bool NotiMessage::onTLSConnect(const  gloox::CertInfo& info){
    return true;
}
inline void NotiMessage::handleMessage( const gloox::Message& msg, gloox::MessageSession* session  ){
    std::time_t ct = std::time(0);
    char* cc = ctime(&ct);
    NSString *time=[NSString stringWithUTF8String:cc];
    NSDictionary *msgDic=@{@"msgID":[NSString stringWithUTF8String: msg.id().c_str()],
                           @"msg":[NSString stringWithUTF8String: msg.body().c_str()],
                           @"from":[NSString stringWithUTF8String: msg.from().bare().c_str()],
                           @"to":[NSString stringWithUTF8String: msg.to().bare().c_str()],
                           @"msgType":[NSString stringWithUTF8String: msg.subject().c_str()],
                           @"event":msg.from().bare()== getUserJID().bare()?[NSString stringWithFormat:@"%i",-1]:[NSString stringWithFormat:@"%i",gloox::MessageEventType::MessageEventDisplayed],
                           @"time":time};
     setMessageID([NSString stringWithUTF8String:msg.id().c_str()],msgDic);
}
inline void NotiMessage::handleLog( gloox::LogLevel level, gloox::LogArea area, const std::string& message ){
    
    NSLog(@"%s",message.c_str());
}

gloox::JID NotiMessage::getUserJID(){
    
        NSString *appGroupDirectoryPath = [[[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.guys"].path   stringByAppendingPathComponent:@"userinfo"] stringByAppendingPathExtension:@"txt"];

        NSMutableDictionary *userInfo=[NSMutableDictionary dictionaryWithContentsOfFile:appGroupDirectoryPath];
        if(!userInfo)
            return gloox::JID();
    
         return gloox::JID(((NSString*)userInfo[@"jid"]).UTF8String);
    
}
void NotiMessage::setMessageID(NSString* _id ,NSDictionary* msg){
    NSString *appGroupDirectoryPath = [[[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.guys"].path   stringByAppendingPathComponent:@"Messages"] stringByAppendingPathExtension:@"txt"];
    NSError *error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:appGroupDirectoryPath])
        [[NSFileManager defaultManager] createFileAtPath:appGroupDirectoryPath contents:nil attributes:@{NSFileAppendOnly:@"NO",NSFileImmutable:@"NO"}]; //Create folder
    if(error){
        NSLog(@" Fail to Create Message File Error : %@",error);
        return;
    }
    NSMutableDictionary *msgD=[NSMutableDictionary dictionaryWithContentsOfFile:appGroupDirectoryPath];
    if(!msgD)
        msgD=[[NSMutableDictionary alloc]init];
    [msgD setObject:msg forKey:_id];
    if([msgD writeToFile:appGroupDirectoryPath atomically:YES])
        NSLog(@"AG: Message Saved");
        NSLog(@"%@",msgD);
        
        
}
void NotiMessage::handleMessageSession(gloox::MessageSession *session){
   // ;
    //for (auto itr=m_msgSession.begin();itr!=m_msgSession.end(); ++itr) {
        
      //  if((*itr)->target()==session->target().bare()){
    NSLog(@"message session");
            m_client->disposeMessageSession(session);
            //m_msgSession.erase(itr)
         //   break;
    ///   }
       
   // }
   // m_msgSession.push_back(session);
}
void NotiMessage::handleMessageEvent( const gloox::JID& from, gloox::MessageEventType event ,const std::string _id) {
    
    

    NSString *appGroupDirectoryPath = [[[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.guys"].path   stringByAppendingPathComponent:@"Messages"] stringByAppendingPathExtension:@"txt"];
     if(!appGroupDirectoryPath)
         return;
    

    NSMutableDictionary *msgD=[NSMutableDictionary dictionaryWithContentsOfFile:appGroupDirectoryPath];
    if(!msgD)
        return;
    NSString *tmpID=[NSString stringWithUTF8String:_id.c_str()];
    if(msgD[tmpID]){
        [msgD[tmpID] setObject:[NSString stringWithFormat:@"%i",event] forKey:@"event"];
    if([msgD writeToFile:appGroupDirectoryPath atomically:YES])
        NSLog(@"AG: Message Event Change :%i",event);
    NSLog(@"%@",msgD);
    
    }
    if(event==gloox::MessageEventOffline && from.bare() == getUserJID().bare()){
        sendNotification([msgD objectForKey:@"msg"], [msgD objectForKey:@"msgID"], [NSString stringWithUTF8String:from.username().c_str()],[NSString stringWithUTF8String: from.bare().c_str()],(MESSAGETYPE)((NSString*)[msgD objectForKey:@"msgType"]).intValue);
    }
    
    
}
void NotiMessage::sendNotification(NSString* msg ,NSString* msgID,NSString* number, NSString* jid,MESSAGETYPE type){
    //if(![token UTF8String] || ![number UTF8String])
    // return;
    
    
    
    
    NSURLComponents * comp=[[NSURLComponents alloc]init];
    [comp setScheme:@"http"];
    [comp setHost:@"18.222.150.253"];
    [comp setPath:@"/push"];
    [comp setPort:@9898];
    NSURLQueryItem *service=[NSURLQueryItem queryItemWithName:@"service" value:@"Guys"];
    NSURLQueryItem* subscriber=[NSURLQueryItem queryItemWithName:@"subscriber" value:number];
    //msgType is the same  Noti. Category
    NSString *apnsStr=[NSString stringWithFormat:@"{\"aps\" : {\"category\":\"%i\", \"alert\" :{\"body\":\"%@\"},\"mutable-content\":1},\"jid\":\"%@\",\"msgID\":\"%@\"}",type,msg,jid,msgID];
    
    NSURLQueryItem* apns=[NSURLQueryItem queryItemWithName:@"uniqush.payload.apns" value:apnsStr];
    NSLog(@"\n\n\n%@",apnsStr);
    
    [comp setQueryItems:@[service,subscriber,apns]];
    
    
    NSMutableURLRequest* request=[NSMutableURLRequest requestWithURL:comp.URL];
    
    
    
    [request setValue:@"application/json; utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    
    
    NSURLSessionConfiguration *config=[NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *sesson=[NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionTask *task=[sesson dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(error){
            NSLog(@"Fail to register Device Error :%@",error);
            return;
        }
        NSLog(@"%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    [task resume];
    
}

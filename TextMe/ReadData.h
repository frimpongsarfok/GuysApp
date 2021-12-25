//
//  ReadData.hpp
//  Guys!
//
//  Created by SARFO KANTANKA FRIMPONG on 7/12/18.
//  Copyright © 2018 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#ifndef ReadData_hpp
#define ReadData_hpp
#import <UIKit/UIKit.h>
#include <stdio.h>
#include <iostream>
#include <vector>
#include <fstream>
#import <sqlite3.h>
#include <gloox/vcard.h>
#include <thread>
#include <future>

#import <gloox/presence.h>

class  AppData{
    
public:
    enum class MESSAGETYPE{TEXT=1,FILE_ASSET_ID=2,FILE_URL=3,YOUTUBE_LINK=4,REPLY=5,DELETE=6,RECEIPT=7};

    struct PartnerInfoType{
        std::string jid;
        std::string  name;
        std::string photo;
        bool registered;
        bool inroster;
        bool inContact;
        std::string lastTimeOnline;
        std::string chat_priority;
        gloox::Presence::PresenceType presence;
        std::string presence_time;
       
    };
    struct ChatInfo{
          int _id;
         NSString* from;
          NSString* to;
          NSString* msg;
          NSString* date;
          gloox::MessageEventType msg_event;
          NSString* msg_ID;
          MESSAGETYPE type;
    };
    typedef std::vector<PartnerInfoType>  PartnersType;
    //num CHAT_MSG_TYPE{TEXT=1,IMG_URL=3,VIDEO_URL=4,IMG_PATH=5,VID_PATH=6,YOUTUBE_LINK=7};
    
    bool m_rosterSorted,m_contactSorted;
private:
    sqlite3 * m_sql3;
  

     NSMutableArray *m_chat;

    std::vector<std::string>m_partnersJID;
    std::string m_dbName;
    
    //sqlite3_stmt *m_partnersStmt;
   
     std::vector<std::tuple<std::string/*id*/,std::string/*to*/,std::string/*message*/,AppData::MESSAGETYPE/*type*/>>m_unsentMsg;
    PartnersType m_partnerInRoster;
    PartnersType m_partnerInContact;
    PartnersType m_partnerInRegistered;
    PartnersType m_partners;
    
    bool m_searching;

    std::map<gloox::JID,std::vector<ChatInfo>> m_chatData;
public:
    //enum MsgStatus{MESSAGE_NOT=1,MESSAGE_SENT=2,MESSAGE_READ=3};
    std::fstream m_fileStream;

     std::tuple< std::string /*jid*/, std::string /*callingcode*/, std::string/*photo*/,std::string /*token*/>m_userInfo;
    
    
    AppData();
     enum Data{SERVER,JID,PASSWORD};
    NSArray * getUser();
    
     std::vector<std::tuple<std::string/*id*/,std::string/*to*/,std::string/*message*/,AppData::MESSAGETYPE/*type*/>> getAllUnsendChats();
    bool setAccount(const std::string jid,const std::string callingCode,const std::string photo=std::string());
  
    bool createTables();
    const std::tuple< std::string /*jid*/, std::string /*callingcode*/, std::string,std::string /*token*/> getUserInfo();
    bool dropUserData();
    std::pair<long/*msg size*/,bool/*new partner*/>  insertNewMessage(const std::string&msg_id,const std::string& from,const std::string& to,const std::string& msg,MESSAGETYPE type,const std::string& dateNtime="");
    std::vector<ChatInfo>& getChats(const std::string partnerJID);
    PartnerInfoType isPartnerExisting(std::string jid);

    void setPartnerInContact(const std::string jid, bool inContact);
    void setPartnerPhoto(std::string jid,std::string photo);
    void setPartnerRegistered(const std::string jid, bool registered);
    void setPartnerInRoster(const std::string jid, bool inRoster);
    void updatePartnerName(const std::string jid, const std::string name);
    void saveDownloadFileID(const std::string msgID,const std::string fileID);
    bool deletePartnerFromChat(const std::string jid);
    void setPartnerLastTimeOnline(const std::string jid, const std::string& lastTimeOnline);
    void addPartner(const PartnerInfoType& partner);
    void setPartnerChatPriority(const std::string jid);
    PartnersType getPartners();
    PartnersType  roster();
    PartnersType  chatRoster();
    PartnersType  contact();
    PartnersType  registered();
    void deletePartner(const std::string jid);
    std::vector<std::string> getPartnersJID();
    bool setDeviceToken(std::string token);
    ~AppData();
    bool contactPartner(const std::string jid);
    bool setMsgStatus(const std::string  bareJId,std::string _id,gloox::MessageEventType status,bool toMe=false);
    void cleanPartnersVar(){
        m_partners.clear();
    }
    
    void setPresence(gloox::JID jid,gloox::Presence::PresenceType type,std::string time);
    void search(std::string value);
    void deleteMessage(const gloox::JID jid,const std::string _id);
    int getUnreadMsgCount(gloox::JID jid);
    std::pair<std::string/*from*/,std::string/*to*/> getToAndFrom4FileUrlSend(const std::string msgID);
    void getChatData();
   
    
    void setFileURLInfo(std::string _id,std::string url);
    const std::string getFileURLInfo(const std::string _d);
    void addPartToGroupPathForContact(NSString *name, NSString *partJID);
    void updatePartGroupContactName(NSString *name, NSString *partJID);
    void setUserInfoInGroup(NSString* jid);
    void sortContact();
    
};



#endif /* ReadData_hpp */


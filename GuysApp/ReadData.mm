//
//  ReadData.cpp
//  GuysApp
//
//  Created by SARFO KANTANKA FRIMPONG on 7/12/18.
//  Copyright © 2018 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#include "ReadData.h"
AppData::AppData():m_sql3(nullptr),m_dbName(std::string()),m_userInfo({}),m_partners({}),m_unsentMsg({}),m_chatData({}),m_rosterSorted(false),m_contactSorted(false),m_searching(false){
    NSString *docuPaths=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *_dbName=[docuPaths stringByAppendingString:@"/GuysApp.db"];
    m_dbName=[_dbName UTF8String];
    m_fileStream=std::fstream(m_dbName,std::ios::in);
    if(!m_fileStream.is_open()){
        sqlite3_config(SQLITE_CONFIG_SERIALIZED);
        if(sqlite3_open([_dbName UTF8String],& m_sql3)==SQLITE_OK){
            std::cout<<"db open successfuly :"<<m_dbName<<std::endl;
              createTables();
        }else{
            std::cout<<"fail to create db at :"<<m_dbName<<std::endl;
        }
    }else{
sqlite3_config(SQLITE_CONFIG_SERIALIZED);
        if(sqlite3_open(m_dbName.c_str(), &m_sql3)!=SQLITE_OK){
            std::cout<<"fail to open db "<<m_dbName<<std::endl;
            return;
        }
        getUserInfo();
       }
    }
    
bool AppData::createTables(){
     char *err=nullptr;
    try {
       
  
        if( sqlite3_exec(m_sql3,"CREATE TABLE IF NOT EXISTS 'ACCOUNT'(JID TEXT,FNAME TEXT,LNAME TEXT ,CALLINGCODE VARCAR(10) ,PHOTO LONGBLOB,PUSH_ID TEXT,PUBSUB_CREATED INT DEFAULT 0);" // USER ACCOUNT // NOT CONSTRAINT BECAUSE  USER DEVICE CAN BE STORED BEFORE REGISTERED
                                "CREATE TABLE IF NOT EXISTS 'PARTNERS' (JID TEXT PRIMARY_KEY NOT NULL,NAME TEXT,PHOTO LONGBLOB,REGISTERED BOOLEAN DEFAULT FALSE,INROSTER BOOLEAN DEFAULT FALSE,INCONTACT BOOLEAN DEFAULT FALSE,LASTTIMEONLINE DATETIME,CHAT_PRIORITY DATETIME DEFAULT CURRENT_TIMESTAMP,PUSH_ID TEXT,PUBSUB_NOTI TEXT,BLOCKED INT DEFAULT 0);" // PARTNERS
                                "CREATE TABLE IF NOT EXISTS 'CHATS' (ID INT PRIMARY_KEY,_FROM TEXT NOT NULL,_TO TEXT NOT NULL,MESSAGE TEXT NOT NULL,DATENTIME DATETIME DEFAULT CURRENT_TIMESTAMP,MSG_EVENT_TYPE INT DEFAULT -1,MSG_ID TEXT NOT NULL,FILE BLOB DEFAULT '',TYPE INT);"
                                "CREATE VIEW PARTNERS_JID_VIEW AS SELECT JID FROM PARTNERS;" // VIEW FOR QUERING PARTNERS NUMBER
                                "CREATE TABLE IF NOT EXISTS 'FILE_URL_MSG_INFO' (MSG_ID TEXT ,URL TEXT, FOREIGN KEY (MSG_ID) REFERENCES CHATS(MSG_ID));"
                         ,0, 0,&err)!=SQLITE_OK){
            throw false;
        }else{
            std::cout<<"tables created successfuly in : "<<m_dbName<<std::endl;
        }
    } catch (bool e) {
        std::cout<<"fail to create tables err : "<<err<<std::endl;
        return false;
    }

    
    return true;
}
AppData::PartnersType AppData::registered(){
    
    if(!m_partners.size())
        getPartners();
    PartnersType tmp{};
    for (auto& partner: m_partners) {
            if(partner.second.registered){
                tmp.push_back(partner.second);
            }
        
    }
    return tmp;
}
//void  AppData::setPubSubCreated(bool created){
//
//
//    sqlite3_stmt *stmt;
//    int rc=sqlite3_prepare_v2(m_sql3, "UPDATE ACCOUNT SET PUBSUB_CREATED=?", -1, &stmt, 0);
//    sqlite3_bind_int(stmt, 1, (int)created);
//    if(rc==SQLITE_OK){
//        int step=sqlite3_step(stmt);
//        if(step!=SQLITE_DONE){
//            std::cout<<"fail to execute partner stmt"<<std::endl;
//            sqlite3_finalize(stmt);
//            return;
//        }else{
//            std::cout<<" ACCOUNT 'PUBSUB_CREATED' updated"<<std::endl;
//            sqlite3_finalize(stmt);
//        }
//    }else{
//        std::cout<<"fail to update ACCOUNT PUBSUB_CREATED"<<std::endl;
//
//    }
//}
//bool AppData::isPubSubCreated(){
//     bool isCreated=false;
//
//
//    sqlite3_stmt *stmt;
//
//    if(sqlite3_prepare(m_sql3, "SELECT PUBSUB_CREATED FROM ACOUNT", -1, &stmt, 0)==SQLITE_OK){
//        int step=sqlite3_step(stmt);
//        if(step==SQLITE_ROW){
//            isCreated=(bool)sqlite3_column_int(stmt, 0);
//        }
//    }else{
//        std::cout<<"file url preparation stmt fail"<<std::endl;
//        return isCreated;
//    }
//    sqlite3_finalize(stmt);
//    return isCreated;
//}
void AppData::saveDownloadFileID(const std::string msgID,const std::string fileID){
    
    if(!msgID.size() && !fileID.size())
        return ;
    
    sqlite3_stmt *stmt;
    int rc=sqlite3_prepare_v2(m_sql3, "UPDATE CHATS SET MESSAGE=?, TYPE=2  WHERE MSG_ID=?", -1, &stmt, 0);
    sqlite3_bind_text(stmt, 1, fileID.c_str(), (int)strlen(fileID.c_str()), 0);
    sqlite3_bind_text(stmt, 2, msgID.c_str(), (int)strlen(msgID.c_str()), 0);
    
    if(rc==SQLITE_OK){
        int step=sqlite3_step(stmt);
        if(step!=SQLITE_DONE){
            std::cout<<"fail to prepare saveDownloadFile  stmt"<<std::endl;
            sqlite3_finalize(stmt);
            
            return;
        }else{
            std::cout<<" file save"<<std::endl;
            sqlite3_finalize(stmt);
        }
    }else{
        std::cout<<"fail to prepare partner stmt for update"<<std::endl;
        
    }
    
}
//insert and update partners;
AppData::PartnerInfoType AppData::isPartnerExisting(std::string jid){
  
    if(!jid.size())
        return {};
    if(m_partners.empty())
        getPartners();
    if(m_partners.find(jid)==m_partners.end()){
        return {};
    }
    return m_partners.find(jid)->second;;
}

void AppData::setPartnerPhoto(std::string jid,std::string photo){
    if(jid.size()&& m_partners.find(jid)!= m_partners.end()){
        m_partners.find(jid)->second.photo=photo;
    }else{
        return;
    }
    sqlite3_stmt *stmt;
    int rc=sqlite3_prepare_v2(m_sql3, "UPDATE PARTNERS SET PHOTO=? WHERE JID=?", -1, &stmt, 0);
    sqlite3_bind_blob(stmt, 1, photo.c_str(), (int)strlen(photo.c_str()), 0);
    sqlite3_bind_text(stmt, 2, jid.c_str(), (int)strlen(jid.c_str()), 0);
    
    if(rc==SQLITE_OK){
        int step=sqlite3_step(stmt);
        if(step!=SQLITE_DONE){
            std::cout<<"fail to execute partner stmt"<<std::endl;
            sqlite3_finalize(stmt);
            
            return;
        }else{
            std::cout<<" partner 'Photo' updated"<<std::endl;
            sqlite3_finalize(stmt);
        }
    }else{
        std::cout<<"fail to prepare partner stmt for update"<<std::endl;
        
    }
 
     
  
  

}
void AppData::setPubSubNotification(std::string jid,std::string node){

    if(jid.size()&& m_partners.find(jid)!= m_partners.end()){
     
        m_partners.find(jid)->second.noti_pubsub_node=node;
    }else{
        return;
    }
 
    sqlite3_stmt *stmt;
    int rc=sqlite3_prepare_v2(m_sql3, "UPDATE PARTNERS SET PUBSUB_NOTI=? WHERE JID=?", -1, &stmt, 0);
    sqlite3_bind_blob(stmt, 1, node.c_str(), (int)strlen(node.c_str()), 0);
    sqlite3_bind_text(stmt, 2, jid.c_str(), (int)strlen(jid.c_str()), 0);
    
    if(rc==SQLITE_OK){
        int step=sqlite3_step(stmt);
        if(step!=SQLITE_DONE){
            std::cout<<"fail to execute partner stmt"<<std::endl;
            sqlite3_finalize(stmt);
            
            return;
        }else{
            std::cout<<" partner partner pubsub notification node updated"<<std::endl;
            sqlite3_finalize(stmt);
        }
    }else{
        std::cout<<"fail to prepare partner stmt for update"<<std::endl;
        
    }
 
     
   
  

}
void AppData::setPartnerRegistered(const std::string jid, bool registered){
    
    
    if(jid.size()&& m_partners.find(jid)!= m_partners.end()){
     
        m_partners.find(jid)->second.registered=registered;
    }else{
        return;
    }
            sqlite3_stmt *stmt;
            int rc=sqlite3_prepare_v2(m_sql3, "UPDATE PARTNERS SET REGISTERED=? WHERE JID=?", -1, &stmt, 0);
            sqlite3_bind_int(stmt, 1, registered);
            sqlite3_bind_text(stmt, 2, jid.c_str(), (int)strlen(jid.c_str()), 0);

            if(rc==SQLITE_OK){
                int step=sqlite3_step(stmt);
                if(step!=SQLITE_DONE){
                    std::cout<<"fail to execute partner 'isRegistered' stmt"<<std::endl;
                    
                    return ;
                }else{
                    std::cout<<" partner 'isRegistered' updated"<<std::endl;
                   
                    sqlite3_finalize(stmt);
                    
                    
                }
                
             }else{
                std::cout<<"fail to prepare partner registered stmt for update "<<std::endl;
                 
                return;
            
            }
    
             
 
}
void AppData::setPartnerInContact(const std::string jid, bool inContact){
   
 
    if(jid.size()&& m_partners.find(jid)!= m_partners.end()){
     
        m_partners.find(jid)->second.inContact=inContact;
    }else{
        return;
    }
    sqlite3_stmt *stmt;
    int rc=sqlite3_prepare_v2(m_sql3, "UPDATE PARTNERS SET INCONTACT=? WHERE JID=?", -1, &stmt, 0);
    sqlite3_bind_int(stmt, 1, inContact);
    sqlite3_bind_text(stmt, 2, jid.c_str(), (int)strlen(jid.c_str()), 0);
    
    if(rc==SQLITE_OK){
        int step=sqlite3_step(stmt);
        if(step!=SQLITE_DONE){
            std::cout<<"fail to execute partner 'inContact' stmt"<<std::endl;
            
            return ;
        }else{
            std::cout<<" partner 'inContact' updated"<<std::endl;
            
            sqlite3_finalize(stmt);
            
           
            
        }
        
    }else{
        std::cout<<"fail to prepare partner incontact stmt for update "<<std::endl;
        
        return;
        
    }
    
   
  
    
//});
 
}

void AppData::setPartnerChatPriority(const std::string jid){
    if(!jid.size())
    return;
  
    std::time_t ct = std::time(0);
    char* cc = ctime(&ct);
    sqlite3_stmt *stmt;
    int rc=sqlite3_prepare_v2(m_sql3, "UPDATE PARTNERS SET CHAT_PRIORITY=? WHERE JID=?", -1, &stmt, 0);
    sqlite3_bind_text(stmt, 1, cc, (int)strlen(cc), 0);
    sqlite3_bind_text(stmt, 2, jid.c_str(), (int)strlen(jid.c_str()), 0);
    
    if(rc==SQLITE_OK){
        int step=sqlite3_step(stmt);
        if(step!=SQLITE_DONE){
            std::cout<<"fail to execute partner 'setPartnerChatPriority' stmt"<<std::endl;
            
            return ;
        }else{
            std::cout<<" partner priority updated \t"<<cc<<std::endl;
            
            sqlite3_finalize(stmt);
            
            
        }
        
    }else{
        std::cout<<"fail to prepare partner setPartnerChatPriority'stmt for update "<<std::endl;
        
        return;
        
    }
    m_partners.find(jid)->second.chat_priority=cc;
}

void AppData::setPartnerInRoster(const std::string jid, bool inRoster){
    if(!jid.size())
        return;

    sqlite3_stmt *stmt;

    int rc=sqlite3_prepare_v2(m_sql3, "UPDATE PARTNERS SET INROSTER = ? WHERE JID = ? ", -1, &stmt, 0);

    if(rc==SQLITE_OK){
        sqlite3_bind_int(stmt, 1, inRoster);
        sqlite3_bind_text(stmt, 2, jid.c_str(),(int)jid.size(), 0);
        int step=sqlite3_step(stmt);
        if(step!=SQLITE_DONE){
            std::cout<<"fail to execute partner 'inRoster' stmt "<<step<<std::endl;
            sqlite3_finalize(stmt);
            return ;
        }else{
             sqlite3_finalize(stmt);
            //m_rosterSorted=false;
            
            m_partners.find(jid)->second.inroster=inRoster;
    
       
            std::cout<<" partner 'inRoster' updated"<<std::endl;
           
       
      
        }
      
        
    }else{
        std::cout<<"fail to prepare partner roster stmt for update "<<std::endl;
        
        return;
        
    }
    

}

void AppData::setPartnerPushID(const std::string jid, std::string pushID){
    if(!jid.size())
        return;

    sqlite3_stmt *stmt;

    int rc=sqlite3_prepare_v2(m_sql3, "UPDATE PARTNERS SET PUSH_ID = ? WHERE JID = ? ", -1, &stmt, 0);

    if(rc==SQLITE_OK){
        sqlite3_bind_text(stmt, 1, pushID.c_str(),(int)pushID.size(), 0);
        sqlite3_bind_text(stmt, 2, jid.c_str(),(int)jid.size(), 0);
        int step=sqlite3_step(stmt);
        if(step!=SQLITE_DONE){
            std::cout<<"fail to execute partner 'pushid' stmt "<<step<<std::endl;
            sqlite3_finalize(stmt);
            return ;
        }else{
             sqlite3_finalize(stmt);
            //m_rosterSorted=false;
            m_partners.find(jid)->second.pushID=pushID;
            std::cout<<" partner 'pushid' updated"<<std::endl;
           
       
      
        }
      
        
    }else{
        std::cout<<"fail to prepare partner roster stmt for update "<<std::endl;
        
        return;
        
    }
    

}
void AppData::updatePartnerName(const std::string jid, const std::string name){
    if(!jid.size())
    return;

    sqlite3_stmt *stmt;
    int rc=sqlite3_prepare_v2(m_sql3, "UPDATE PARTNERS SET NAME =? WHERE JID = ? ", -1, &stmt, 0);
    
    if(rc==SQLITE_OK){
        sqlite3_bind_text(stmt, 1, name.c_str(), (int)strlen(name.c_str()), 0);
        sqlite3_bind_text(stmt, 2, jid.c_str(), (int)strlen(jid.c_str()), 0);
        int step=sqlite3_step(stmt);
        if(step!=SQLITE_DONE){
            std::cout<<"fail to execute partner 'updateName' stmt "<<step<<std::endl;
            sqlite3_finalize(stmt);
            
            return ;
        }else{
            std::cout<<" partner 'Name' updated"<<std::endl;
            sqlite3_finalize(stmt);
            
            
            
        }
        
        
    }else{
        std::cout<<"fail to prepare 'updatePartnerName' stmt for update "<<std::endl;
        
        return;
        
    }
    updatePartGroupContactName([NSString stringWithUTF8String:name.c_str()],[NSString stringWithUTF8String:jid.c_str()]);
    m_partners.find(jid)->second.name=name;
    
    
    
}

void AppData::deletePartner(const std::string jid){
    char *err=nullptr;
    
    sqlite3_exec(m_sql3, ("DELETE FROM CHATS WHERE _TO='"+jid+"'"+" OR _FROM='"+jid+"'").c_str(), nullptr, nullptr, &err);
    if(err ){
        std::cout<<"fail to delete partners  chat:"<<err<<std::endl;
    }
    if(err)
        sqlite3_free(err);
    sqlite3_exec(m_sql3, ("DELETE FROM PARTNERS WHERE JID='"+jid+"'").c_str(), nullptr, nullptr, &err);
    if(err ){
        std::cout<<"fail to delete partners :"<<err<<std::endl;
        
    }
    if(err)
        sqlite3_free(err);
 
    m_partners.erase(jid);
    
  

}
void AppData::setPartnerLastTimeOnline(const std::string jid, const std::string& lastTimeOnline){
    if(!jid.size())
        return;

    
    
    sqlite3_stmt *stmt;
    int rc=sqlite3_prepare_v2(m_sql3, "UPDATE PARTNERS SET LASTTIMEONLINE=? WHERE JID=?", -1, &stmt, 0);
    sqlite3_bind_text(stmt, 1, lastTimeOnline.c_str(), (int)strlen(jid.c_str()), 0);
    sqlite3_bind_text(stmt, 2, jid.c_str(), (int)strlen(jid.c_str()), 0);
    
    if(rc==SQLITE_OK){
        int step=sqlite3_step(stmt);
        sqlite3_finalize(stmt);
        if(step!=SQLITE_DONE){
            std::cout<<"fail to execute partner 'lastTimeOnline' stmt"<<std::endl;
            
            return ;
        }else{
            std::cout<<" partner 'lastTimeOnline' updated"<<std::endl;
            
            
            sqlite3_finalize(stmt);
            
            
            
        }
        
    }else{
        std::cout<<"fail to prepare partner lasttimeonline stmt for update "<<std::endl;
        
        return;
        
    }
    //update m_partner var by setting partner last time online if partner exist in m_partners

   
    if(!m_partners.size())
            getPartners();
    m_partners.find(jid)->second.lastTimeOnline=lastTimeOnline;
   
}


void AppData::addPartner(const PartnerInfoType& partner){
    if(partner.jid.empty())
        return;

    sqlite3_stmt *stmt;
    int rc=SQLITE_FAIL;
    
    rc=sqlite3_prepare_v2(m_sql3,"INSERT INTO PARTNERS(JID,NAME,REGISTERED,INROSTER,INCONTACT,PUSH_ID) SELECT ?,?,?,?,?,?  WHERE NOT EXISTS (SELECT JID FROM PARTNERS WHERE JID=?)", -1, &stmt, 0);
 
   
        sqlite3_bind_text(stmt, 1,partner.jid.c_str(), (int)strlen(partner.jid.c_str()), 0);
        sqlite3_bind_text(stmt, 2, partner.name.c_str(), (int)strlen(partner.name.c_str()), 0);
        sqlite3_bind_int(stmt, 3, partner.registered);
        sqlite3_bind_int(stmt, 4, partner.inroster);
        sqlite3_bind_int(stmt, 5, partner.inContact);
        sqlite3_bind_text(stmt, 6,partner.pushID.c_str(), (int)strlen(partner.pushID.c_str()), 0);
        sqlite3_bind_text(stmt, 7,partner.jid.c_str(), (int)strlen(partner.jid.c_str()), 0);
        if(rc==SQLITE_OK){
            int step=sqlite3_step(stmt);
            if(step!=SQLITE_DONE){
                std::cout<<"Fail to execute add partner  stmt"<<std::endl;
                return ;
            }else{
                 sqlite3_finalize(stmt);
              
                m_partners.insert({partner.jid,partner});
    
                std::cout<<"added \t"<<partner.jid<<" "<<partner.name<<std::endl;
              
            }
    }else{
            std::cout<<"fail to prepare add partner stmt to store "<<rc<<"\t"<<partner.jid<<"\t"<<partner.name<<std::endl;
        
        

    }
    //ADD PARTNER NAME AND JID TO APP GROUP FOR NOTIFICATION USE PURPOSE
    NSString *name=[NSString stringWithUTF8String:(partner.name.size()?partner.name.c_str():gloox::JID(partner.jid).username().c_str())];
    NSString *jid=[NSString stringWithUTF8String:partner.jid.c_str()];
    addPartToGroupPathForContact(name, jid);

    
    
}


void AppData::setFileURLInfo(std::string _id, std::string url){

    
    sqlite3_stmt *stmt;
    int rc=SQLITE_FAIL;
    
    rc=sqlite3_prepare_v2(m_sql3,"INSERT INTO FILE_URL_MSG_INFO(MSG_ID,URL) VALUES(?,?);", -1, &stmt, 0);
    
    
    sqlite3_bind_text(stmt, 1,_id.c_str(), (int)strlen(_id.c_str()), 0);
    sqlite3_bind_text(stmt, 2, url.c_str(), (int)strlen(url.c_str()), 0);

    if(rc==SQLITE_OK){
        int step=sqlite3_step(stmt);
        if(step!=SQLITE_DONE){
            std::cout<<"Fail to execute add partner  stmt"<<std::endl;
            return ;
        }else{
            sqlite3_finalize(stmt);
     
            std::cout<<"saved url: \t"<<_id<<"\t"<<url<<std::endl;
        }
    }else{
        std::cout<<"fail to prepare file url statement "<<std::endl;
        
        
        
    }
}
const std::string AppData::getFileURLInfo(const std::string _id){
    
    std::string url={};
    if(_id.empty())
        return url;
    sqlite3_stmt *stmt;
   
    if(sqlite3_prepare(m_sql3, ("SELECT URL FROM FILE_URL_MSG_INFO WHERE MSG_ID='"+_id+"'").c_str(), -1, &stmt, 0)==SQLITE_OK){
        int step=sqlite3_step(stmt);
        
        if(step==SQLITE_ROW){
           
              url=std::string((char*)sqlite3_column_text(stmt, 0));
    
        }
    }else{
        std::cout<<"file url preparation stmt fail"<<std::endl;
        return url;
    }
    sqlite3_finalize(stmt);
    return url;
}
bool AppData::deletePartnerFromChat(const std::string jid){
    char *err=nullptr;

        sqlite3_exec(m_sql3, ("DELETE FROM CHATS WHERE _TO='"+jid+"'"+" OR _FROM='"+jid+"'").c_str(), nullptr, nullptr, &err);
        if(err ){
            std::cout<<"fail to delete partners :"<<err<<std::endl;
            
            if(err)
              sqlite3_free(err);
            return false;
        }


    m_chatData.erase(jid);
    return true;
}
AppData::PartnersMapType  AppData::getPartners(){
    
    if(m_partners.size())
        return  m_partners;
  sqlite3_stmt *stmt;
        
    try {
       
            if(sqlite3_prepare_v2(m_sql3, "SELECT *FROM PARTNERS ORDER BY NAME", -1, &stmt, 0)==SQLITE_OK){
    
                while(sqlite3_step(stmt)==SQLITE_ROW){
                    std::string jid=std::string((char*)sqlite3_column_text(stmt, 0));
                     std::string name=std::string((char*)sqlite3_column_text(stmt, 1));
                    
                    std::string photo,lastTimeOnline,chatPriority,pushID,noti_pubsub_node;
                    noti_pubsub_node=photo=lastTimeOnline=chatPriority=pushID={};
                    if(sqlite3_column_bytes(stmt, 2))
                        photo=(char*)sqlite3_column_blob(stmt, 2);
                    else
                        photo=std::string();
                    bool registered=sqlite3_column_int(stmt, 3);
                    bool inRoster=sqlite3_column_int(stmt, 4);
                     bool inContact=sqlite3_column_int(stmt, 5);
                     lastTimeOnline=std::string();
                    if(sqlite3_column_bytes(stmt, 6))
                        lastTimeOnline=std::string((char*)sqlite3_column_text(stmt, 6));
                    if(sqlite3_column_bytes(stmt, 7))
                        chatPriority=std::string((char*)sqlite3_column_text(stmt, 7));
                    if(sqlite3_column_bytes(stmt, 8)){
                        pushID=(char*)sqlite3_column_text(stmt, 8);
                      
                    }
                    if(sqlite3_column_bytes(stmt, 9)){
                        noti_pubsub_node=(char*)sqlite3_column_text(stmt, 9);
                    }
                    bool blocked=sqlite3_column_int(stmt, 10);
                    m_partners.insert({jid,{jid,(name.empty()?gloox::JID(jid).username():name),photo,registered,inRoster,inContact,lastTimeOnline,chatPriority,gloox::Presence::Unavailable ,pushID,noti_pubsub_node,blocked}});
               
                   
                }
                
            }else{
                std::cout<<"fail to get all partners  "<<std::endl;
                sqlite3_finalize(stmt);
                
                
                return m_partners;
            }
    
    } catch (std::exception exc) {
        
    }
    sqlite3_finalize(stmt);
    return m_partners;
   
     
  
    
}


void AppData::setBlockPartner(const std::string jid,bool toggle){
    if(jid.size()&& m_partners.find(jid)!= m_partners.end()){
        m_partners.find(jid)->second.blocked=toggle;
    }else{
        return;
    }
    sqlite3_stmt *stmt;
    int rc=sqlite3_prepare_v2(m_sql3, "UPDATE PARTNERS SET BLOCKED=? WHERE JID=?", -1, &stmt, 0);
    sqlite3_bind_int(stmt, 1, toggle);
    sqlite3_bind_text(stmt, 2, jid.c_str(), (int)strlen(jid.c_str()), 0);
    
    if(rc==SQLITE_OK){
        int step=sqlite3_step(stmt);
        if(step!=SQLITE_DONE){
            std::cout<<"fail to execute setBlockPartner stmt"<<std::endl;
            sqlite3_finalize(stmt);
            
            return;
        }else{
            std::cout<<" partner  ("<< jid <<") "<<(toggle?"blocked":"unblocked")<<std::endl;
            sqlite3_finalize(stmt);
        }
    }else{
        std::cout<<"fail to prepare partner stmt for update"<<std::endl;
        
    }
 
    
}
AppData::PartnersType AppData::getPartnerBlockList(){
    PartnersType list;
    for(auto part:getPartners()){
        if(part.second.blocked)list.push_back(part.second);
    }
    return  list;

    
}
AppData::PartnersType AppData::contact(std::string searchKey){
    if(m_partners.empty()){
        getPartners();
    }
    PartnersType tmp{};
    
    if(searchKey.size()){
        for (auto & part : m_partners ) {
            
            //bool found=(part.name.substr(0,value.size())==value);
            std::size_t found = part.second.name.find(searchKey);
            if (found!=std::string::npos && part.second.inContact){
             //if (found && part.inContact){
                  tmp.push_back(part.second);
                
            }
        }
    }else{
        for (auto& partner: m_partners) {
            if(partner.second.inContact){
                tmp.push_back(partner.second);
            }
        }
    }
    
 
    std::sort(tmp.begin(), tmp.end(), []( PartnerInfoType  first,  PartnerInfoType  second){

         if(!first.name.size() ||
            ((int)first.name[0])<65 ||
            ((int)first.name[0] >122)
          )
             return false;

         if(first.name[0]<second.name[0]){
             return true;
         }else{
             return false;

         }



     });
   return tmp;
    
    
    
}



AppData::PartnersType  AppData::chatRoster(){
    AppData::PartnersType tmp={};
    if(m_chatData.empty()){
        getChatData();
    }
    for(auto jid:m_chatData){
        if(!jid.second.empty()){
            auto part=isPartnerExisting(jid.first);
           //std::cout<<" chat roster order "<<part.jid<<" "<<part.lastTimeOnline<<std::endl;
            tmp.push_back(part);
        }
    }
    return tmp;
}


AppData::PartnersType  AppData::roster(){
    if(!m_partners.size())
        getPartners();
    
         //sort according to priority
    
    PartnersType tmp{};
      
        for (auto & partner : m_partners) {
            if(partner.second.inroster && (partner.second.jid!=m_userInfo.JID.bare())){
                tmp.push_back(partner.second);
               
            }
        }
    
    //if(!m_rosterSorted){
   
      //  m_rosterSorted=true;
    //}
    
    return tmp;
    
}


 std::pair<long/*msg size*/,bool/*new partner*/>  AppData::insertNewMessage(const std::string& msg_id,const std::string& from,const std::string& to,const std::string& msg,MESSAGETYPE type,const std::string& dateNtime){
    
    
    char* cc=nullptr;
    char *err=nullptr;
    if(dateNtime.size()){
        cc=const_cast<char*>(dateNtime.c_str());
    }else{
        
        std::time_t ct = std::time(0);
        cc = ctime(&ct);
    }
    
    
    sqlite3_exec(m_sql3,("INSERT INTO CHATS(_FROM,_TO,MESSAGE,MSG_ID,TYPE,DATENTIME) VALUES ('"+from+"','"+to+"','"+msg+"','"+msg_id+"',"+std::to_string((int)type)+",'"+cc+"');").c_str(),0 , 0, &err);
    if(err){
        std::cout<<"Fail to insert now row : "<<err<<std::endl;
        return {};
    }else{
      
    }
     std::cout<<"message inserted "<<to<<" \t "<<from<< "\t"<<cc<<std::endl;
    sqlite3_stmt *stmt;
    if(sqlite3_prepare(m_sql3,"SELECT LAST_INSERT_ROWID();", -1, &stmt,0)!=SQLITE_OK){
        std::cout<<"fail to select last insert_row id"<<std::endl;
        
        return {};
    }
     
    int step=sqlite3_step(stmt);
    if(step==SQLITE_ROW){
       
      
        
     
        int _id=sqlite3_column_int(stmt,0);
        NSString *_from=[NSString stringWithUTF8String:from.c_str()];
        NSString *_to=[NSString stringWithUTF8String:to.c_str()];
        NSString *_msg=[NSString stringWithUTF8String:msg.c_str()];
        
        NSString* date=[NSString stringWithUTF8String:cc] ;
        gloox::MessageEventType msg_event=(gloox::MessageEventType)-1;
        NSString *_msg_ID=[NSString stringWithUTF8String:msg_id.c_str()];
        ChatInfo info={_id,_from,_to,_msg,date,msg_event,_msg_ID,type};
        //insert message if not exist
        bool inRoster=false;
        std::string myJID=m_userInfo.JID.bare();
          auto tmp=&getChats(from==myJID?to:from);
            tmp->push_back(info);
            std::string  sJID=from==myJID?to:from;
            if(sJID==myJID)
                return {(long )sqlite3_column_int(stmt,0),inRoster};
            
        
            
            PartnerInfoType part=isPartnerExisting(sJID);
            if(part.jid.empty()){
                    part.jid=sJID;
                    part.inroster=YES;
                    part.registered=YES;
                    part.inContact=NO;
                    addPartner(part);
                    
            }
        
         
     
        return {(long )sqlite3_column_int(stmt,0),inRoster};
    }
     return  {};
}

void AppData::getChatData(){
    if(m_chatData.size())
        return;
    m_chatData={};
    std::string myJID=m_userInfo.JID.bare();
  //  for (auto roster:roster()) {
       sqlite3_stmt * stmt;
        //SELECT ID,_FROM,_TO,MESSAGE,DATENTIME,MSG_EVENT_TYPE,MSG_ID,TYPE FROM CHATS WHERE (_FROM='"+roster.jid+"' AND _TO='"+myJID+"') OR (_FROM='"+myJID+"' AND _TO='"+roster.jid+"')
        if(sqlite3_prepare_v2(m_sql3, "SELECT DISTINCT ID,_FROM,_TO,MESSAGE,DATENTIME,MSG_EVENT_TYPE,MSG_ID,TYPE FROM CHATS INNER JOIN PARTNERS ON PARTNERS.JID=CHATS._FROM OR PARTNERS.JID=CHATS._TO ORDER BY CHAT_PRIORITY"
                                      " ;", -1, &stmt, 0)!=SQLITE_OK){
            std::cout<<"fail to prepare chat stmt : "<<sqlite3_errmsg(m_sql3)<<std::endl;
            return;
        }
//        sqlite3_bind_text(stmt, 1, roster.jid.c_str(), (int)strlen(roster.jid.c_str()), 0);
//        sqlite3_bind_text(stmt, 2, myJID.c_str(), (int)strlen(myJID.c_str()), 0);
//        sqlite3_bind_text(stmt, 3, myJID.c_str(), (int)strlen(myJID.c_str()), 0);
//        sqlite3_bind_text(stmt, 4, roster.jid.c_str(), (int)strlen(roster.jid.c_str()), 0);
//
        
        while (sqlite3_step(stmt)==SQLITE_ROW) {
            
            int _id=sqlite3_column_int(stmt, 0);
            NSString *from=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stmt, 1)];
            NSString *to=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stmt, 2)];
            NSString *msg=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stmt, 3)];
            NSString* date=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stmt,4)] ;
            gloox::MessageEventType msg_event=(gloox::MessageEventType)sqlite3_column_int(stmt, 5);
            NSString *msg_ID=[NSString stringWithUTF8String:(char*)sqlite3_column_text(stmt, 6)];
            MESSAGETYPE msg_type=(MESSAGETYPE)sqlite3_column_int(stmt, 7);
            ChatInfo info={_id,from,to,msg,date,msg_event,msg_ID,msg_type};
            std::string myJID=m_userInfo.JID.bare();
            std::string jid=from.UTF8String==myJID?to.UTF8String:from.UTF8String;
            auto partChat=m_chatData.find(jid);
            //NSLog(@"FROM :%@ TO :%@ DATENTIME :%@ MSG_ID :%@",from,to,date,msg_ID);
            //std::cout<<"mmdmdmdmdmdmdmdmdmdd"<<std::endl;
            if(partChat==m_chatData.end()){
                std::vector<ChatInfo> tmpChat={};
                tmpChat.push_back(info);
                m_chatData.insert({jid,tmpChat});
              
            }else{
                partChat->second.push_back(info);
            }
           
          
        }
    
        sqlite3_finalize(stmt);
    //}
    //std::sort(m_chatData.begin(),m_chatData.end()-1 , [](auto first,secord())

}
std::vector<AppData::ChatInfo>& AppData::getChats(const std::string partnerJID){
 //  @autoreleasepool{
      if(m_chatData.empty())
            getChatData();
       if(m_chatData.find(partnerJID)==m_chatData.end())
           m_chatData.insert({partnerJID,{}});
      auto& tmp=m_chatData.find(partnerJID)->second;
      return tmp;

  // }
    
    
}


bool AppData::setAccount(const std::string jid,const std::string fname, const std::string lname,const std::string callingCode,const std::string photo,const std::string token){
    char *err=nullptr;
    m_userInfo.JID=gloox::JID(jid);
    m_userInfo.FNAME=fname;
    m_userInfo.LNAME=lname;
    m_userInfo.extCODE=callingCode;
    m_userInfo.PHOTO=photo;
    m_userInfo.PUSH_ID=token;
      

    dropUserData(false);
    //"INSERT INTO ACCOUNT(JID,FNAME,LNAME,CALLINGCODE,PHOTO,PUSH_ID) VALUES( '"+jid+"','"+fname+"','"+lname+"','"+callingCode+"','"+photo+"','"+token+"')"
    sqlite3_stmt *stmt;
   auto rc=sqlite3_prepare_v2(m_sql3,"INSERT INTO ACCOUNT(JID,FNAME,LNAME,CALLINGCODE,PHOTO,PUSH_ID) VALUES( ?,?,?,?,?,?);", -1, &stmt, 0);
 
        sqlite3_bind_text(stmt, 1,jid.c_str(), (int)strlen(jid.c_str()), 0);
        sqlite3_bind_text(stmt, 2,fname.c_str(), (int)strlen(fname.c_str()), 0);
        sqlite3_bind_text(stmt, 3,lname.c_str(), (int)strlen(lname.c_str()), 0);
        sqlite3_bind_text(stmt, 4,callingCode.c_str(), (int)strlen(callingCode.c_str()), 0);
        sqlite3_bind_text(stmt, 5,photo.c_str(), (int)strlen(photo.c_str()), 0);
        sqlite3_bind_text(stmt, 6,token.c_str(), (int)strlen(token.c_str()), 0);
        if(rc==SQLITE_OK){
            int step=sqlite3_step(stmt);
            if(step==SQLITE_DONE){
                sqlite3_finalize(stmt);
                
               
            }else{
                sqlite3_finalize(stmt);
            std::cout<<"fail to store info err:"<<err<<std::endl;
                return false;
           
            }
        }
         std::cout<<"info saved" <<std::endl;
   

   
    
    setUserInfoInGroup([NSString stringWithUTF8String:jid.c_str()]);
       return true;

}
AppData::~AppData(){
    sqlite3_close_v2(m_sql3);
    m_partners.clear();
   
  
    m_dbName.clear();
    m_fileStream.close();
    m_userInfo={};
}
const AppData::AccountInfo AppData::getUserInfo(){
    if(m_userInfo.JID.bare().size())
        return m_userInfo;
    try {
        
    } catch (std::exception e) {
       
    }
    sqlite3_stmt *stmt;
     if(sqlite3_prepare(m_sql3, "SELECT *FROM ACCOUNT", -1, &stmt, 0)==SQLITE_OK){
         int step=sqlite3_step(stmt);
         if(step==SQLITE_ROW && step!=0){
   
             if(sqlite3_column_bytes(stmt, 0))
                 m_userInfo.JID=gloox::JID(std::string((char*)sqlite3_column_text(stmt, 0)));
             if(sqlite3_column_bytes(stmt, 1))
                 m_userInfo.FNAME=std::string((char*)sqlite3_column_text(stmt, 1));
             if(sqlite3_column_bytes(stmt, 2))
                 m_userInfo.LNAME=std::string((char*)sqlite3_column_text(stmt, 2));
             if(sqlite3_column_bytes(stmt, 3))
                 m_userInfo.extCODE=std::string((char*)sqlite3_column_text(stmt, 3));
             if(sqlite3_column_bytes(stmt, 4))
                 m_userInfo.PHOTO=std::string((char*)sqlite3_column_text(stmt, 4));
             if(sqlite3_column_bytes(stmt, 5))
                 m_userInfo.PUSH_ID=std::string((char*)sqlite3_column_text(stmt, 5));
               
         
         }
     }else{
        
          std::cout<<"info preparation fail"<<std::endl;
         return m_userInfo;
     }
    
    
    sqlite3_finalize(stmt);
    
    
    return m_userInfo;
}

bool AppData::dropUserData(BOOL allData){
  
   
    char* err=nullptr;
   
   
  
    if(allData){
        if(sqlite3_exec(m_sql3, "DELETE FROM PARTNERS; DELETE FROM CHATS;DELETE FROM FILE_URL_MSG_INFO;", 0, 0, &err)!=SQLITE_OK){
            std::cout<<"fail to delete info err:"<<err<<std::endl;
            return false;
        }
        m_chatData.clear();
        m_partners.clear();
    }
   
    if(sqlite3_exec(m_sql3, "DELETE FROM ACCOUNT;", 0, 0, &err)!=SQLITE_OK){
        std::cout<<"fail to delete info err:"<<err<<std::endl;
        return false;
    }
    m_userInfo={};
    std::cout<<"data deleted"<<std::endl;
    return true;
    
}

bool AppData::setDeviceToken(std::string token){
    if(!token.size())
        return false;
    char* err=nullptr;
    if(sqlite3_exec(m_sql3,( "UPDATE ACCOUNT SET PUSH_ID='"+token+"'").c_str(), 0, 0, &err)!=SQLITE_OK){
        std::cout<<"fail to update  push id err:"<<err<<std::endl;
        return false;
    }
    m_userInfo.PUSH_ID=token;
    
    std::cout<<"deveice token update"<<std::endl;
    return true;
    
}

//if id!=-1 are set from message functions
bool AppData::setMsgStatus(const std::string  bareJId,std::string _id,gloox::MessageEventType status ,bool toMe){

    char* err=nullptr;
  
    if(toMe){
        if(status==gloox::MessageEventDisplayed){
            if(sqlite3_exec(m_sql3,( "UPDATE CHATS SET MSG_EVENT_TYPE="+std::to_string(gloox::MessageEventDisplayed)+" WHERE _FROM='"+bareJId+"' AND MSG_EVENT_TYPE ==-1").c_str(), 0, 0, &err)!=SQLITE_OK){
                std::cout<<"fail to sent msg event not send"<<err<<std::endl;
                
              
                return false;
            }
        }
        return true;
    }

    auto&tmp=getChats(bareJId);
    NSString *tmpID=[NSString stringWithUTF8String:_id.c_str()];
    if(status==gloox::MessageEventDisplayed){
        if(sqlite3_exec(m_sql3,( "UPDATE CHATS SET MSG_EVENT_TYPE="+std::to_string(gloox::MessageEventDisplayed)+" WHERE _TO='"+bareJId+"' AND MSG_EVENT_TYPE ==2").c_str(), 0, 0, &err)!=SQLITE_OK){
            std::cout<<"fail to sent msg event not send"<<err<<std::endl;
            return false;
        }
        
      
        for (int n=(int)tmp.size()-1;n>-1;--n) {
            if( ([tmpID isEqualToString:tmp[n].msg_ID] && status>=16) || (  [tmpID isEqualToString:tmp[n].msg_ID]  && tmp[n].msg_event<status) ){
                tmp[n].msg_event=status;
              
            }
        }
         std::cout<<"msg event changedss : "<<status<<std::endl;
        return true;
    }
    if(sqlite3_exec(m_sql3,( "UPDATE CHATS SET MSG_EVENT_TYPE="+std::to_string(status)+" WHERE (MSG_ID='"+_id+"' AND MSG_EVENT_TYPE >=16) OR  (MSG_ID='"+_id+"' AND "+std::to_string(status)+">MSG_EVENT_TYPE) ").c_str(), 0, 0, &err)!=SQLITE_OK){
        std::cout<<"fail to sent msg event not send"<<err<<std::endl;
        return false;
    }

  
    for (int n=(int)tmp.size()-1;n>-1;--n) {
        if( ([tmpID isEqualToString:tmp[n].msg_ID] && status>=16) || (  [tmpID isEqualToString:tmp[n].msg_ID]  && tmp[n].msg_event<status) ){
            tmp[n].msg_event=status;
            std::cout<<"msg event changed : "<<status<<std::endl;
            break;
            
        }
    }
    
    return true;
    
}

std::vector<std::tuple<std::string/*id*/,std::string/*to*/,std::string/*message*/,AppData::MESSAGETYPE/*type*/>> AppData::getAllUnsendChats(){
    
 
    sqlite3_stmt * stmt;
    std::string myJID=m_userInfo.JID.bare();;
        if(sqlite3_prepare(m_sql3,("SELECT MSG_ID,_TO,MESSAGE,TYPE FROM CHATS WHERE (MSG_EVENT_TYPE=-1 AND _FROM='"+myJID+"' AND _TO!='"+myJID+"') OR (MSG_EVENT_TYPE=32 AND _FROM='"+myJID+"' AND _TO!='"+myJID+"') ").c_str(), -1, &stmt, 0)!=SQLITE_OK){
        std::cout<<"fail to prepare chat stmt : "<<sqlite3_errmsg(m_sql3)<<std::endl;
        
        return m_unsentMsg;
    }
 
    while (sqlite3_step(stmt)==SQLITE_ROW) {
         std::string _id=std::string((char*)sqlite3_column_text(stmt, 0));
         std::string to=std::string((char*)sqlite3_column_text(stmt, 1));
         std::string msg=std::string((char*)sqlite3_column_text(stmt, 2));
          AppData::MESSAGETYPE msg_type=(AppData::MESSAGETYPE)sqlite3_column_int(stmt, 3);
         m_unsentMsg.push_back({_id,to,msg,msg_type});
    }
    sqlite3_finalize(stmt);
    return m_unsentMsg;
    
    
    
}

void AppData::deleteMessage(const gloox::JID jid,const std::string _id){
    char *err;
    if(sqlite3_exec(m_sql3,( "UPDATE CHATS SET MESSAGE='message was deleted',TYPE=6 WHERE MSG_ID='"+_id+"'").c_str(), 0, 0, &err)!=SQLITE_OK){
        std::cout<<"fail to delete msg "<<err<<std::endl;
        return;
    }
   
    for (auto& tmpChat :getChats(jid.bare())){
        if(tmpChat.msg_ID.UTF8String==_id){
            tmpChat.type=MESSAGETYPE::DELETE;
            tmpChat.msg=@"this message was deleted";
            
        }
        
    }
    
     std::cout<<"message was deleted successfully"<<std::endl;
}

void AppData::setPresence(gloox::JID jid,gloox::Presence::PresenceType type,std::string time){
   
    
  //  dispatch_queue_t t=dispatch_queue_create("setPresence", NULL);
   // dispatch_async(t, ^{

        for(auto& part:m_partners){
            if(gloox::JID(part.second.jid).bare()==jid.bare()){
                part.second.presence=type;
                part.second.lastTimeOnline=time;
                break;
            }
        }
        
   

   // });

    
}
int AppData::getUnreadMsgCount(gloox::JID jid){
    sqlite3_stmt * stmt;

    
    int total=0;
    std::string jids=jid.bare();
        if(sqlite3_prepare(m_sql3,("SELECT COUNT(MSG_EVENT_TYPE) FROM CHATS WHERE MSG_EVENT_TYPE=-1 AND _FROM='"+jids+"'").c_str(), -1, &stmt, 0)!=SQLITE_OK){
            std::cout<<"fail to prepare chat stmt : "<<sqlite3_errmsg(m_sql3)<<std::endl;
            
            return total;
        }
        
        if(sqlite3_step(stmt)==SQLITE_ROW) {
            total=sqlite3_column_int(stmt, 0);
        
        }
        sqlite3_finalize(stmt);
    

    return total;
    
}

std::pair<std::string/*from*/,std::string/*to*/> AppData::getToAndFrom4FileUrlSend(const std::string msgID){
    
    sqlite3_stmt * stmt;
    if(msgID.empty())
        return {};
    if(sqlite3_prepare(m_sql3,("SELECT _FROM,_TO FROM CHATS WHERE MSG_ID='"+msgID+"';").c_str(), -1, &stmt, 0)!=SQLITE_OK){
        std::cout<<"fail to prepare chat stmt : "<<sqlite3_errmsg(m_sql3)<<std::endl;
        
        return {};
    }
    
    if(sqlite3_step(stmt)!=SQLITE_ROW) {
        //sqlite3_finalize(stmt);
        return {};
    }
    std::string to=std::string((char*)sqlite3_column_text(stmt, 1));
    std::string from=std::string((char*)sqlite3_column_text(stmt, 0));
    sqlite3_finalize(stmt);
    return {from,to};
    
    
    
}
void AppData::addPartToGroupPathForContact(NSString *name, NSString *partJID){
    NSString *appGroupDirectoryPath = [[[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.guys"].path   stringByAppendingPathComponent:@"ContactInfo"] stringByAppendingPathExtension:@"txt"];
    NSError *error;

    if (![[NSFileManager defaultManager] fileExistsAtPath:appGroupDirectoryPath])
        [[NSFileManager defaultManager] createFileAtPath:appGroupDirectoryPath contents:nil attributes:@{NSFileAppendOnly:@"NO",NSFileImmutable:@"NO"}]; //Create folder
    if(error){
        NSLog(@" addPartToGroupPathForContact Error : %@",error);
        return;
    }
    //if([@"Hello" writeToFile:appGroupDirectoryPath atomically:YES encoding:NSUTF8StringEncoding error:&error])
    NSMutableDictionary *nameNJid=[NSMutableDictionary dictionaryWithContentsOfFile:appGroupDirectoryPath];
    if(!nameNJid)
        nameNJid=[[NSMutableDictionary alloc]init];
   

    [nameNJid setObject:name forKey:partJID];
    
        NSLog(@"Group Contact Updated");
    
    
}


void AppData::updatePartGroupContactName(NSString *name, NSString *partJID){
    NSString *appGroupDirectoryPath = [[[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.guys"].path   stringByAppendingPathComponent:@"ContactInfo"] stringByAppendingPathExtension:@"txt"];
    NSError *error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:appGroupDirectoryPath])
        [[NSFileManager defaultManager] createFileAtPath:appGroupDirectoryPath contents:nil attributes:@{NSFileAppendOnly:@"NO",NSFileImmutable:@"NO"}]; //Create folder
    if(error){
        NSLog(@" addPartToGroupPathForContact Error : %@",error);
        return;
    }
    NSMutableDictionary *nameNJid=[NSMutableDictionary dictionaryWithContentsOfFile:appGroupDirectoryPath];
    if(!nameNJid)
        nameNJid=[[NSMutableDictionary alloc]init];
    
    if([nameNJid objectForKey:partJID])
        [nameNJid setValue:name forKey:partJID];
    [nameNJid writeToFile:appGroupDirectoryPath atomically:YES];
        
    
    
}
void AppData::setUserInfoInGroup(NSString* jid){
    NSString *appGroupDirectoryPath = [[[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.guys"].path   stringByAppendingPathComponent:@"userinfo"] stringByAppendingPathExtension:@"txt"];
    NSError *error;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:appGroupDirectoryPath])
        [[NSFileManager defaultManager] createFileAtPath:appGroupDirectoryPath contents:nil attributes:@{NSFileAppendOnly:@"NO",NSFileImmutable:@"NO"}]; //Create folder
    if(error){
        NSLog(@" Fail to Create Message File Error : %@",error);
        return;
    }
    //if([@"Hello" writeToFile:appGroupDirectoryPath atomically:YES encoding:NSUTF8StringEncoding error:&error])
    NSMutableDictionary *userInfo=[NSMutableDictionary dictionaryWithContentsOfFile:appGroupDirectoryPath];
    if(!userInfo)
        userInfo=[[NSMutableDictionary alloc]init];
    [userInfo setDictionary:@{@"jid":jid}];
    [userInfo writeToFile:appGroupDirectoryPath atomically:YES];
        NSLog(@"Group: UserInfo Saved");
    NSLog(@"%@",userInfo);
        
        
        
}

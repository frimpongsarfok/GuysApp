//
//  ReadData.cpp
//  Guys!
//
//  Created by SARFO KANTANKA FRIMPONG on 7/12/18.
//  Copyright © 2018 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#include "ReadData.h"
AppData::AppData():m_sql3(nullptr),m_dbName(std::string()),m_userInfo({}),m_partners({}),m_partnersJID({}),m_partnerInContact({}),m_partnerInRoster({}),m_partnerInRegistered({}),m_unsentMsg({}),m_chatData({}),m_rosterSorted(false),m_contactSorted(false),m_searching(false){
    NSString *docuPaths=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *_dbName=[docuPaths stringByAppendingString:@"/Guys!.db"];
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
       
  
        if( sqlite3_exec(m_sql3,"CREATE TABLE IF NOT EXISTS 'ACCOUNT'(JID TEXT PRIMARY_KEY,CALLINGCODE VARCAR(10) NOT NULL,PHOTO LONGBLOB,DEVICE_TOKEN TEXT);" // USER ACCOUNT
                                "CREATE TABLE IF NOT EXISTS 'PARTNERS' (JID TEXT PRIMARY_KEY NOT NULL,NAME TEXT,PHOTO LONGBLOB,REGISTERED BOOLEAN DEFAULT FALSE,INROSTER BOOLEAN DEFAULT FALSE,INCONTACT BOOLEAN DEFAULT FALSE,LASTTIMEONLINE DATETIME,CHAT_PRIORITY DATETIME DEFAULT CURRENT_TIMESTAMP);" // PARTNERS
                                "CREATE TABLE IF NOT EXISTS 'CHATS' (ID INT PRIMARY_KEY,_FROM TEXT NOT NULL,_TO TEXT NOT NULL,MESSAGE TEXT NOT NULL,DATENTIME DATETIME DEFAULT CURRENT_TIMESTAMP,MSG_EVENT_TYPE INT DEFAULT -1,MSG_ID TEXT NOT NULL,FILE BLOB DEFAULT '',TYPE INT);"
                                "CREATE VIEW PARTNERS_JID_VIEW AS SELECT JID FROM PARTNERS;" // VIEW FOR QUERING PARTNERS NUMBER
                                "CREATE TABLE IF NOT EXISTS 'FILE_URL_MSG_INFO' (MSG_ID TEXT ,URL TEXT, FOREIGN KEY (MSG_ID) REFERENCES CHATS(MSG_ID));"
                         ,0, 0,&err)!=SQLITE_OK){
            throw false;
        }else
            std::cout<<"tables created successfuly in : "<<m_dbName<<std::endl;
       
    } catch (bool e) {
        std::cout<<"fail to create tables err : "<<err<<std::endl;
        return false;
    }

    
    return true;
}
AppData::PartnersType AppData::registered(){
    if(!m_partners.size())
        getPartners();
    if(! m_partnerInRegistered.size()){
        for (auto& partner: m_partners) {
            if(partner.registered){
                m_partnerInRegistered.push_back(partner);
            }
        }
    }
    return m_partnerInRegistered;
}
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
    
    for (auto& part: m_partners) {
        if(part.jid==jid){
            return part;
        }
    }
    PartnerInfoType partner;
    sqlite3_stmt * stmt;

   
    if(sqlite3_prepare_v2(m_sql3,"SELECT * FROM PARTNERS WHERE JID = ? ", -1, &stmt, nullptr)!=SQLITE_OK){
        std::cout<<"fail to  check partner : "<<std::endl;
        return partner;
    }
    
   sqlite3_bind_text(stmt, 1, jid.c_str(), (int)strlen(jid.c_str()), 0);
    int rc=sqlite3_step(stmt);
    if(rc==SQLITE_ROW){
        partner.jid=std::string((char*)sqlite3_column_text(stmt, 0));
        partner.name=std::string((char*)sqlite3_column_text(stmt, 1));
        if(sqlite3_column_bytes(stmt, 2))
            partner.photo=(char*)sqlite3_column_blob(stmt, 2);
        else
            partner.photo=std::string();
          partner.registered=sqlite3_column_int(stmt, 3);
         partner.inroster=sqlite3_column_int(stmt, 4);
         partner.inContact=sqlite3_column_int(stmt, 5);
        sqlite3_finalize(stmt);
        
        m_partners.push_back(partner);
        
        return partner;
        
        
    }
    return partner;
    
}

void AppData::setPartnerPhoto(std::string jid,std::string photo){
    if(!jid.size() && !photo.size())
        return ;
 
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
    std::async(std::launch::async,[this,&jid,&photo]()mutable{
    
        for (auto& partner : m_partners) {
            if(partner.jid==jid){
               partner.photo=photo;
                break;
            }
            
        }
    });
    std::async(std::launch::async,[this,&jid,&photo]()mutable{
        
        for (auto& partner : m_partnerInRoster) {
            if(partner.jid==jid){
                partner.photo=photo;
                 break;
            }
            
        }
    });
    std::async(std::launch::async,[this,&jid,&photo]()mutable{
        
        for (auto& partner : m_partnerInContact) {
            if(partner.jid==jid){
                partner.photo=photo;
                 break;
            }
            
        }
    });

}

void AppData::setPartnerRegistered(const std::string jid, bool registered){
    if(!jid.size())
        return;
  
    

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
    
 std::async(std::launch::async,[this,&jid,&registered]()mutable{
    for (auto& partner : m_partners) {
        if(partner.jid==jid){
            partner.registered=registered;
             break;
        }
    }
 });
    std::async(std::launch::async,[this,&jid,&registered]()mutable{
        for (auto& partner : m_partnerInContact) {
            if(partner.jid==jid){
                partner.registered=registered;
                 break;
            }
        }
    });
    std::async(std::launch::async,[this,&jid,&registered]()mutable{
        for (auto& partner : m_partnerInRoster) {
            if(partner.jid==jid){
                partner.registered=registered;
                 break;
            }
        }
    });
}
void AppData::setPartnerInContact(const std::string jid, bool inContact){
    if(!jid.size())
        return;
 
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
    
   
 //std::async(std::launch::async,[this,&jid,&inContact]()mutable{
    for (auto& partner : m_partners) {
        if(partner.jid==jid){
            partner.inContact=inContact;
            if(inContact){
                  m_partnerInContact.insert(m_partnerInContact.begin(),partner);
            }else{
                PartnersType::iterator it=m_partnerInContact.begin();
                for (;it!=m_partnerInContact.end();) {
                    if(it->jid==jid){
                        m_partnerInContact.erase(it);
                        break;
                    }
                    it++;
                }
                break;
            }
           
          
            
        }
    }
    m_contactSorted=false;
    
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
    
    //update m_partner var by setting partner photo if partner exist in m_partners
 std::async(std::launch::async,[this,&jid,cc]()mutable{
    for (auto & partner : m_partners) {
        if(partner.jid==jid){
            partner.chat_priority=cc;
             break;
        }
    }
 });
  

    
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
            
            for (auto& partner : m_partners) {
                if(partner.jid==jid){
                    partner.inroster=inRoster;
                    if(inRoster){
                     
                        PartnersType::iterator it=m_partnerInRoster.begin();
                      
                        
                        for (;it!=m_partnerInRoster.end();) {
                            if((it)->jid==jid){
                                if(it->inroster){
                                    break;
                                }else{
                                    it->inroster=true;
                                }
                                    
                                
                            }else if(it ==m_partnerInRoster.end()-1){
                                m_partnerInRoster.insert(m_partnerInRoster.end(),partner);
                            }
                            
                            it++;
                        }
                    }else{
                        PartnersType::iterator it=m_partnerInRoster.begin();
                        for (;it!=m_partnerInRoster.end();) {
                            if((it)->jid==jid){
                                m_partnerInRoster.erase(it);
                                break;
                            }
                            it++;
                        }
                         break;
                    }
                    
                    
                    
                }
            }

            std::cout<<" partner 'inRoster' updated"<<std::endl;
           
       
      
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
    
   std::async(std::launch::async,[this,&jid,&name]()mutable{
    for (auto& partner : m_partners) {
        if(partner.jid==jid){
            partner.name=name;
        }
    }
       m_contactSorted=false;
   });
    
    std::async(std::launch::async,[this,&jid,&name]()mutable{
        for (auto& partner : m_partnerInContact) {
            if(partner.jid==jid){
                partner.name=name;
            }
        }
        m_contactSorted=false;
    });
    std::async(std::launch::async,[this,&jid,&name]()mutable{
        for (auto& partner : m_partnerInRoster) {
            if(partner.jid==jid){
                partner.name=name;
            }
        }
        m_contactSorted=false;
    });
   
    
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
    m_contactSorted=false;
    m_rosterSorted=false;
    PartnersType::iterator it=m_partners.begin();
    for (; it!=m_partners.end(); ) {
        if(it->jid==jid){
            m_partners.erase(it);
            break;
        }
        ++it;
    }
    PartnersType::iterator itr=m_partnerInRoster.begin();
    for (; itr!=m_partnerInRoster.end(); ) {
        if(itr->jid==jid){
            m_partners.erase(itr);
            break;
        }
        ++itr;
    }
    PartnersType::iterator itc=m_partnerInContact.begin();
    for (; itc!=m_partnerInContact.end(); ) {
        if(itc->jid==jid){
            m_partners.erase(itc);
            break;
        }
    }
    ++itc;

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
     std::async(std::launch::async,[this,&jid,&lastTimeOnline]()mutable{
    for (auto& partner : m_partners) {
        if(partner.jid==jid){
            partner.lastTimeOnline=lastTimeOnline;
            break;
        }
    }
     });

}


void AppData::addPartner(const PartnerInfoType& partner){
    if(partner.jid.empty())
        return;

    sqlite3_stmt *stmt;
    int rc=SQLITE_FAIL;
    
    rc=sqlite3_prepare_v2(m_sql3,"INSERT INTO PARTNERS(JID,NAME,REGISTERED,INROSTER,INCONTACT) VALUES(?,?,?,?,?);", -1, &stmt, 0);
 
   
        sqlite3_bind_text(stmt, 1,partner.jid.c_str(), (int)strlen(partner.jid.c_str()), 0);
        sqlite3_bind_text(stmt, 2, partner.name.c_str(), (int)strlen(partner.name.c_str()), 0);
        sqlite3_bind_int(stmt, 3, partner.registered);
        sqlite3_bind_int(stmt, 4, partner.inroster);
        sqlite3_bind_int(stmt, 5, partner.inContact);
        if(rc==SQLITE_OK){
            int step=sqlite3_step(stmt);
            if(step!=SQLITE_DONE){
                std::cout<<"Fail to execute add partner  stmt"<<std::endl;
                return ;
            }else{
                 sqlite3_finalize(stmt);
                 if(partner.inroster){
                    
                     m_partnerInRoster.push_back(partner);
                 }
                if(partner.inContact){
                    m_partnerInContact.push_back(partner);
                }
               
                m_partners.push_back(partner);
                std::cout<<"added \t"<<partner.jid<<" "<<partner.name<<std::endl;
    
            }
    }else{
            std::cout<<"fail to prepare add partner stmt to store "<<rc<<"\t"<<partner.jid<<"\t"<<partner.name<<std::endl;
        
        

    }
    
    NSString *name=[NSString stringWithUTF8String:(partner.name.size()?partner.name.c_str():gloox::JID(partner.jid).username().c_str())];
    NSString *jid=[NSString stringWithUTF8String:partner.jid.c_str()];
    addPartToGroupPathForContact(name, jid);
    
    
}

void AppData::sortContact(){
    std::sort(m_partnerInContact.begin(), m_partnerInContact.end(), []( PartnerInfoType  first,  PartnerInfoType  second){
        if(!first.name.size())
            return true;
        
        if(first.name[0]<second.name[0]){
            return true;
        }else{
            return false;
            
        }
        
        
        
    });
    
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


    
    return true;
}
AppData::PartnersType  AppData::getPartners(){
    
    if(m_partners.size())
        return  m_partners;
  sqlite3_stmt *stmt;
        
    try {

            if(sqlite3_prepare_v2(m_sql3, "SELECT *FROM PARTNERS ORDER BY NAME ASC", -1, &stmt, 0)==SQLITE_OK){
    
                while(sqlite3_step(stmt)==SQLITE_ROW){
                    std::string jid=std::string((char*)sqlite3_column_text(stmt, 0));
                     std::string name=std::string((char*)sqlite3_column_text(stmt, 1));
                    
                    std::string photo,lastTimeOnline,chatPriority;
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
         
                    m_partners.push_back({jid,name,photo,registered,inRoster,inContact,lastTimeOnline,chatPriority,gloox::Presence::Unavailable});
                    m_partnersJID.push_back(jid);
                }

            }else{
                sqlite3_finalize(stmt);
                return m_partners;
            }
    
    } catch (std::exception exc) {
        
    }
    sqlite3_finalize(stmt);
     
    
    return m_partners;
    
}

AppData::PartnersType AppData::contact(){
    if(!m_partnerInContact.size())
        getPartners();
    if(m_searching)
        return m_partnerInContact;
    if(! m_partnerInContact.size()){
        for (auto& partner: m_partners) {
            if(partner.inContact){
                m_partnerInContact.push_back(partner);
            }
        }
    }

    return m_partnerInContact;
    
    
    
}

std::vector<std::string> AppData::getPartnersJID(){
    
    if(!m_partners.size())
        
        getPartners();
    
    
    
    m_partnersJID.clear();
    
    m_partnersJID={};
    
    for (auto partner : m_partners) {
        
        m_partnersJID.push_back(partner.jid);
        
    }
    
    return m_partnersJID;
    
    
    
}

AppData::PartnersType  AppData::chatRoster(){
    AppData::PartnersType tmp={};
    for(auto part:roster()){
        auto chat=m_chatData.find(part.jid);
        if(chat->second.size()){
            std::cout<<"4848484848488484 "<<chat->first.bare()<<std::endl;
            tmp.push_back(part);
        }
        
    }
    return tmp;
}


AppData::PartnersType  AppData::roster(){
    if(!m_partners.size())
        getPartners();
    
         //sort according to priority
    
    if(!m_partnerInRoster.size()){
      
        for (auto & partner : m_partners) {
            if(partner.inroster && partner.jid!=std::get<0>(m_userInfo)){
                m_partnerInRoster.push_back(partner);
                std::cout<<"roster partners :"<<partner.jid<<std::endl;
            }
        }
    }
    //if(!m_rosterSorted){
        std::sort(m_partnerInRoster.begin(), m_partnerInRoster.end(), []( PartnerInfoType & first, PartnerInfoType & second){
             NSDateFormatter * dateFormatter=[[NSDateFormatter alloc]init];
           dateFormatter.dateFormat = @"E MMM dd HH:mm:ss yyyy\n";
            //dateFormatter.timeZone =[NSTimeZone timeZoneForSecondsFromGMT:0];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
            dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
             NSDate *date1=[dateFormatter dateFromString:[NSString stringWithUTF8String:first.chat_priority.c_str()]];
             NSDate *date2=[dateFormatter dateFromString:[NSString stringWithUTF8String:second.chat_priority.c_str()]];
             if([date1 timeIntervalSinceDate:date2]>0){
                 return true;
             }
             return false;
               
        });
      //  m_rosterSorted=true;
    //}
    
    return m_partnerInRoster;
    
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
     std::cout<<"message inserted "<<to<<" \t "<<from<< "\t"<<msg_id<<std::endl;
    sqlite3_stmt *stmt;
    if(sqlite3_prepare(m_sql3,"SELECT LAST_INSERT_ROWID();", -1, &stmt,0)!=SQLITE_OK){
        std::cout<<"fail to select last insert_row id"<<std::endl;
        
        return {};
    }
     
    int step=sqlite3_step(stmt);
    if(step==SQLITE_ROW){
       
      
        
        std::string myJID=std::get<0>(getUserInfo());
        auto tmp=&getChats(from==myJID?to:from);
        
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
   
            tmp->push_back(info);
            std::string  sJID=from==myJID?to:from;
            if(sJID==myJID)
                return {(long )sqlite3_column_int(stmt,0),inRoster};
            
            for(auto& part:m_partnerInRoster){
                if(sJID==part.jid){
                    inRoster=true;
                    break;
                }
                
            }
            
            PartnerInfoType part=isPartnerExisting(sJID);
            if(part.jid.empty()){
                    part.jid=sJID;
                    part.inroster=YES;
                    part.registered=YES;
                    part.inContact=NO;
                    addPartner(part);
            }else if(!inRoster){
                
                setPartnerInRoster(part.jid, YES);
                setPartnerRegistered(part.jid, YES);
                
              
                
            }
            
            if(m_partnerInRoster.size()>1){
                std::cout<<" is in rosters"<<std::endl;
                for(auto& part:m_partnerInRoster){
                    if(sJID==part.jid){
                        std::swap(m_partnerInRoster[0], part);
                        setPartnerChatPriority(sJID);
                        break;
                    }
                }
            }
           
        //}else{
          //  return {};
        //}
        return {(long )sqlite3_column_int(stmt,0),inRoster};
    }
     return  {};
}

void AppData::getChatData(){
    if(m_chatData.size())
        return;
    m_chatData={};
    std::string myJID=std::get<0>(getUserInfo());
    for (auto roster:roster()) {
       sqlite3_stmt * stmt;
        if(sqlite3_prepare(m_sql3,  ("SELECT ID,_FROM,_TO,MESSAGE,DATENTIME,MSG_EVENT_TYPE,MSG_ID,TYPE FROM CHATS WHERE (_FROM='"+roster.jid+"' AND _TO='"+myJID+"') OR (_FROM='"+myJID+"' AND _TO='"+roster.jid+"')  ;").c_str(), -1, &stmt, 0)!=SQLITE_OK){
            std::cout<<"fail to prepare chat stmt : "<<sqlite3_errmsg(m_sql3)<<std::endl;
            
            return;
        }
        std::vector<ChatInfo> tmpChat={};
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
            tmpChat.push_back(info);
            NSLog(@" from %@ \t to %@ \t msg :%@  \tID :%@",from,to,msg,msg_ID);
        }
        m_chatData.insert({roster.jid,tmpChat});
        
        
    }

}
std::vector<AppData::ChatInfo>& AppData::getChats(const std::string partnerJID){
   @autoreleasepool{
      if(m_chatData.empty())
            getChatData();
      // if(m_chatData.find(partnerJID)->first.bare().empty())
       //    m_chatData.insert({gloox::JID(partnerJID),{}});
      auto& tmp=m_chatData.find(partnerJID)->second;
      return tmp;

   }
    
    
}


bool AppData::setAccount(const std::string jid,const std::string callingCode,const std::string photo){
    char *err=nullptr;
    dropUserData();
        if(sqlite3_exec(m_sql3,("INSERT INTO ACCOUNT(JID,CALLINGCODE,PHOTO) VALUES('"+jid+"','"+callingCode+"','"+photo+"')").c_str(),0 , 0, &err)!=SQLITE_OK){
            std::cout<<"fail to store info err:"<<err<<std::endl;
            
            return false;
            
        }
         std::cout<<"info saved" <<std::endl;
   
    std::get<0>(m_userInfo)=jid;
    std::get<1>(m_userInfo)=callingCode;
    std::get<2>(m_userInfo)=photo;

   
   
    setUserInfoInGroup([NSString stringWithUTF8String:jid.c_str()]);
       return true;

}
AppData::~AppData(){
    sqlite3_close_v2(m_sql3);
    m_partners.clear();
    m_partnersJID.clear();
    m_partnerInRoster.clear();
    m_partnerInContact.clear();
    m_dbName.clear();
    m_fileStream.close();
    m_userInfo={};
}
const std::tuple< std::string /*jid*/, std::string /*callingcode*/, std::string,std::string /*token*/> AppData::getUserInfo(){
    if(std::get<0> (m_userInfo).size())
        return m_userInfo;
    try {
        
    } catch (std::exception e) {
       
    }
    sqlite3_stmt *stmt;
     if(sqlite3_prepare(m_sql3, "SELECT *FROM ACCOUNT", -1, &stmt, 0)==SQLITE_OK){
         int step=sqlite3_step(stmt);
         if(step==SQLITE_ROW && step!=0){
             std::string jid=(char*)sqlite3_column_text(stmt, 0);
             std::string callinCode=(char*)sqlite3_column_text(stmt, 1);
             std::string photo=std::string();
             std::string token=std::string();
             
             if(sqlite3_column_bytes(stmt, 3))
                  token=(char*)sqlite3_column_text(stmt,3);
             if(sqlite3_column_text(stmt, 2))
                  photo=(char*)sqlite3_column_text(stmt, 2);
             m_userInfo={jid,callinCode,photo,token};
         
         }
     }else{
        
          std::cout<<"info preparation fail"<<std::endl;
         return m_userInfo;
     }
    
    
    sqlite3_finalize(stmt);
    
    
    return m_userInfo;
}

bool AppData::dropUserData(){
  
   
    char* err=nullptr;
   
    if(sqlite3_exec(m_sql3, "DELETE FROM ACCOUNT", 0, 0, &err)!=SQLITE_OK){
        std::cout<<"fail to delete info err:"<<err<<std::endl;
 
        
     
        return false;
    }
    

    std::cout<<"data deleted"<<std::endl;
    return true;
    
}

bool AppData::setDeviceToken(std::string token){
    if(!token.size())
        return false;
    char* err=nullptr;
    if(sqlite3_exec(m_sql3,( "UPDATE ACCOUNT SET DEVICE_TOKEN='"+token+"'").c_str(), 0, 0, &err)!=SQLITE_OK){
        std::cout<<"fail to delete info err:"<<err<<std::endl;
        return false;
    }
    std::get<3>(m_userInfo)=token;
    
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
    std::string myJID=std::get<0>(getUserInfo());
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
void AppData::search(std::string value){
    if(value.empty() && value==" "){
        m_searching=false;
        return;
    }
    m_searching=true;
    m_partnerInContact.clear();
    for (PartnerInfoType& part : m_partners ) {
        
        //bool found=(part.name.substr(0,value.size())==value);
        std::size_t found = part.name.find(value);
        if (found!=std::string::npos && part.inContact){
         //if (found && part.inContact){
              m_partnerInContact.push_back(part);
            
        }
    }
    
}
void AppData::setPresence(gloox::JID jid,gloox::Presence::PresenceType type,std::string time){
   
    
    dispatch_queue_t t=dispatch_queue_create("setPresence", NULL);
    dispatch_async(t, ^{
        for(auto& part:m_partnerInRoster){
            if(gloox::JID(part.jid).bare()==jid.bare()){
                part.presence=type;
                if(type==gloox::Presence::Unavailable){
                    part.presence_time=time;
                }
                break;
            }
        }
        for(auto& part:m_partners){
            if(gloox::JID(part.jid).bare()==jid.bare()){
                part.presence=type;
                if(type==gloox::Presence::Unavailable){
                    part.presence_time=time;
                }
                break;
            }
        }
        
        for(auto& part:m_partnerInContact){
            if(gloox::JID(part.jid).bare()==jid.bare()){
                part.presence=type;
                if(type==gloox::Presence::Unavailable){
                    part.presence_time=time;
                }
                break;
            }
        }

    });

    
}
int AppData::getUnreadMsgCount(gloox::JID jid){
    sqlite3_stmt * stmt;
  
   
    
    
    
    int total=0;
    std::string jids=jid.bare();
        if(sqlite3_prepare(m_sql3,("SELECT COUNT(MSG_EVENT_TYPE) FROM CHATS WHERE MSG_EVENT_TYPE =-1 AND _FROM='"+jids+"' ").c_str(), -1, &stmt, 0)!=SQLITE_OK){
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
    if([nameNJid writeToFile:appGroupDirectoryPath atomically:YES])
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
    if([nameNJid writeToFile:appGroupDirectoryPath atomically:YES])
        NSLog(@"Group Contact Name Updated");
    
    
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
    if([userInfo writeToFile:appGroupDirectoryPath atomically:YES])
        NSLog(@"Group: UserInfo Saved");
    NSLog(@"%@",userInfo);
        
        
        
}

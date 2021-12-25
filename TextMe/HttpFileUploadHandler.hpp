//
//  HttpFileUploadHandler.hpp
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 4/29/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#ifndef HttpFileUploadHandler_hpp
#define HttpFileUploadHandler_hpp
#include <string>
#include <stdio.h>


class HttpFileUploadHandler{
    
public:
    
    enum SLOTTYPE{GET,PUT,FILE_INFO};

    enum HttpFileUploadResult{Successful,Error,SvrCapNotFound,FileTooLarge};
    virtual void handleSendFileResult(HttpFileUploadResult result)=0;
    virtual void handleSlot(const std::string _id,const std::string slot,const std::string fileID,SLOTTYPE type,const std::string filetype,bool resend)=0;
    
};


#endif /* HttpFileUploadHandler_hpp */

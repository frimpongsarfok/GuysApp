//
//  MyLastActivity.hpp
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 6/29/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#ifndef MyLastActivity_hpp
#define MyLastActivity_hpp

#import <gloox/client.h>
#include <stdio.h>
#include <gloox/tag.h>
#import <gloox/stanzaextension.h>
#import <gloox/lastactivityhandler.h>

class JID;
class ClientBase;
using namespace gloox;
class MyLastActivity : public IqHandler
{
public:
    class Query : public StanzaExtension
    {
    public:
        Query( const Tag* tag = 0 );
        
        Query( const std::string& status, long seconds );
        
        virtual ~Query();
        
        long seconds() const { return m_seconds; }
        
        const std::string& status() const { return m_status; }
        
        // reimplemented from StanzaExtension
        virtual const std::string& filterString() const;
        
        // reimplemented from StanzaExtension
        virtual StanzaExtension* newInstance( const Tag* tag ) const
        {
            return new Query( tag );
        }
        
        // reimplemented from StanzaExtension
        virtual Tag* tag() const;
        
        // reimplemented from StanzaExtension
        virtual StanzaExtension* clone() const
        {
            return new Query( *this );
        }
        
    private:
        long m_seconds;
        std::string m_status;
        
    };
    
    MyLastActivity( Client* parent );
    
    virtual ~MyLastActivity();
    
    void query( const gloox::JID& jid );
    
    void registerLastActivityHandler( LastActivityHandler* lah ) { m_lastActivityHandler = lah; }
    
    void removeLastActivityHandler() { m_lastActivityHandler = 0; }
    
    void resetIdleTimer();
    
    // reimplemented from IqHandler
    virtual bool handleIq( const IQ& iq );
    
    // reimplemented from IqHandler
    virtual void handleIqID( const IQ& iq, int context );
    
private:

    LastActivityHandler* m_lastActivityHandler;
    gloox::ClientBase* m_parent;
    
    time_t m_active;
    
};






#endif /* MyLastActivity_hpp */

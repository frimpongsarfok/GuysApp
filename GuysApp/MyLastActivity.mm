//
//  MyLastActivity.cpp
//  Nosy
//
//  Created by SARFO KANTANKA FRIMPONG on 6/29/19.
//  Copyright © 2019 SARFO KANTANKA FRIMPONG. All rights reserved.
//

#include "MyLastActivity.h"




#include <gloox/disco.h>
#include <gloox/discohandler.h>
#include <gloox/clientbase.h>
#include <gloox/error.h>
#include <gloox/lastactivityhandler.h>

#include <cstdlib>


    
    // ---- LastActivity::Query ----
    MyLastActivity::Query::Query( const Tag* tag )
    : StanzaExtension( ExtLastActivity ), m_seconds(0 )
    {
        if( !tag || tag->name() != "query" || tag->xmlns() != XMLNS_LAST )
            return;
        
        if( tag->hasAttribute( "seconds" ) )
            m_seconds = atoi( tag->findAttribute( "seconds" ).c_str() );
        
        m_status = tag->cdata();
    }
    
    MyLastActivity::Query::Query( const std::string& _status, long _seconds )
    : StanzaExtension( ExtLastActivity ), m_seconds( _seconds ),
    m_status( _status )
    {
    }
    
    MyLastActivity::Query::~Query()
    {
    }
    
    const std::string& MyLastActivity::Query::filterString() const
    {
        static const std::string filter = "/iq/query[@xmlns='" + XMLNS_LAST + "']"
        "|/presence/query[@xmlns='" + XMLNS_LAST + "']";
        return filter;
    }
    
    Tag* MyLastActivity::Query::tag() const
    {
        Tag* t = new Tag( "query" );
        t->setXmlns( XMLNS_LAST );
       // t->addAttribute( "seconds", m_seconds );
        t->setCData( m_status );
        return t;
    }
    // ---- ~LastActivity::Query ----
    
    // ---- LastActivity ----
    MyLastActivity::MyLastActivity( Client* parent )
    : m_lastActivityHandler( 0 ), m_parent( parent ),
    m_active( time ( 0 ) )
    {
        if( m_parent )
        {
            m_parent->registerStanzaExtension( new Query() );
            m_parent->registerIqHandler( this, ExtLastActivity );
            m_parent->disco()->addFeature( XMLNS_LAST );
        }
    }
    
    MyLastActivity::~MyLastActivity()
    {
        if( m_parent )
        {
            m_parent->disco()->removeFeature( XMLNS_LAST );
            m_parent->removeIqHandler( this, ExtLastActivity );
            m_parent->removeIDHandler( this );
        }
    }
    
void MyLastActivity::query( const gloox::JID& jid )
    {
        IQ iq( IQ::Get, jid, m_parent->getID() );
        iq.addExtension( new Query() );
        m_parent->send( iq, this, 0 );
    }
    
    bool MyLastActivity::handleIq( const IQ& iq )
    {
        const Query* q = iq.findExtension<Query>( ExtLastActivity );
        if( !q || iq.subtype() != IQ::Get )
            return false;
        
        IQ re( IQ::Result, iq.from(), iq.id() );
        re.addExtension( new Query( EmptyString, static_cast<long>( time( 0 ) - m_active ) ) );
        m_parent->send( re );
        
        return true;
    }
    
    void MyLastActivity::handleIqID( const IQ& iq, int /*context*/ )
    {
        if( !m_lastActivityHandler )
            return;
        
        if( iq.subtype() == IQ::Result )
        {
            const Query* q = iq.findExtension<Query>( ExtLastActivity );
            if( !q || q->seconds() < 0 )
                return;
            
            m_lastActivityHandler->handleLastActivityResult( iq.from(), q->seconds(), q->status() );
        }
        else if( iq.subtype() == IQ::Error && iq.error() )
            m_lastActivityHandler->handleLastActivityError( iq.from(), iq.error()->error() );
    }
    
    void MyLastActivity::resetIdleTimer()
    {
        m_active = time( 0 );
    }
    
    

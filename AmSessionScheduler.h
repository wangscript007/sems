/*
 * $Id: AmSessionScheduler.h,v 1.1.2.4 2005/06/01 12:00:24 rco Exp $
 *
 * Copyright (C) 2002-2003 Fhg Fokus
 *
 * This file is part of sems, a free SIP media server.
 *
 * sems is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version
 *
 * For a license to use the ser software under conditions
 * other than those described here, or to purchase support for this
 * software, please contact iptel.org by e-mail at the following addresses:
 *    info@iptel.org
 *
 * sems is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License 
 * along with this program; if not, write to the Free Software 
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef _AmSessionScheduler_h_
#define _AmSessionScheduler_h_

#include "AmSession.h"
#include "AmEventQueue.h"

#include <set>
using std::set;

class AmSessionScheduler: 
    public AmThread,
    public AmEventHandler
{
    enum { InsertSession, RemoveSession };
    static AmSessionScheduler* _instance;

    unsigned char   buffer[AUDIO_BUFFER_SIZE];
    set<AmSession*> sessions;
    AmEventQueue    events;

    AmSessionScheduler();
    ~AmSessionScheduler();

    void processAudio(unsigned int ts);
    /**
     * Process pending DTMF events
     */
    void processDtmfEvents();

    // AmThread interface
    void run();
    void on_stop();
    
    // AmEventHandler interface
    void process(AmEvent* e);

public:
    static AmSessionScheduler* instance();
    void addSession(AmSession* s);
    void removeSession(AmSession* s);

};


#endif

// Local Variables:
// mode:C++
// End:






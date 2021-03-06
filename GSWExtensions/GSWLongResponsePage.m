/** GSWLongResponsePage.m - <title>GSWeb: Class GSWLongResponsePage</title>

   Copyright (C) 2002-2004 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Sep 2002
   
   $Revision$
   $Date$
   $Id$
   
   <abstract></abstract>

   This file is part of the GNUstep Web Library.

   <license>
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
   
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
   
   You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
   </license>
**/

#include "config.h"

RCS_ID("$Id$")

#include "GSWExtWOCompatibility.h"
#include "GSWLongResponsePage.h"
#include <GNUstepBase/NSObject+GNUstepBase.h>

@interface GSWLongResponsePage (Private)
-(void) _setCancelled:(BOOL)cancelled;
-(void) _setResult:(id)result;
-(id)_result;
-(void)_setException:(NSException*)exception;
-(NSException*)_exception;
@end

//===================================================================================
@implementation GSWLongResponsePage

-(id)init
{
  if ((self=[super init]))
    {
      _selfLock=[NSRecursiveLock new];
    }
  return self;
}

-(void)dealloc
{
  DESTROY(_selfLock);
  [super dealloc];
}

/** Locks the page **/
-(void) lock
{
  [self subclassResponsibility: _cmd];
};


/** Unlock the page **/
-(void) unlock
{
  [self subclassResponsibility: _cmd];
};

-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{
  [self lock];

  if (_refreshInterval>0 && !_done/*_keepRefreshing*/)
    {
      NSString *url=nil;
      NSString *header=nil;

      url=(NSString*)[aContext urlWithRequestHandlerKey:@"cr"
                               path:nil 
                               queryString:nil];

      header=[NSString stringWithFormat:@"%d;url=%@%@/%@.GSWMetaRefresh",
                       (int)_refreshInterval,
                       url,
                       [[aContext session]sessionID],
                       [aContext contextID]];

      [aResponse setHeader:header
                 forKey:@"Refresh"];
    };
  // Exec action on the first time
  if (!_performingAction) 
    {      
      _performingAction = YES;

      [NSThread detachNewThreadSelector:@selector(_perform)
                toTarget:self
                withObject:nil];
    };
  [super appendToResponse:aResponse
         inContext:aContext];
  [self unlock];
};

-(id)threadExited:(NSNotification*)notif
{
  NSThread* thread=nil;
  thread=[notif object];

  //  threadDict = [thread threadDictionary];
//  NSDebugMLLog(@"low",@"threadDict=%@",threadDict);
//  adaptorThread=[threadDict objectForKey:GSWThreadKey_DefaultAdaptorThread];
//  NSDebugMLLog(@"low",@"adaptorThread=%@",adaptorThread);
//  [threadDict removeObjectForKey:GSWThreadKey_DefaultAdaptorThread];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                        name:NSThreadWillExitNotification
                                        object:thread];
  return nil; //??
};

-(void)_perform
{
  id result=nil;
  NSAutoreleasePool* arp = nil;

  arp = [NSAutoreleasePool new];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                        selector:@selector(threadExited:)
                                        name:NSThreadWillExitNotification
                                        object:[NSThread currentThread]];
  NS_DURING
    {
      [self _setResult:nil];
      result=[self performAction];
      
      if (!_cancelled)
        _done=YES; //???
      [self _setResult:result];
    }
  NS_HANDLER
    {
      RETAIN(localException);
      DESTROY(arp);
      AUTORELEASE(localException);
      [localException raise];
    }
  NS_ENDHANDLER;
  DESTROY(arp);
};

/** Set status (Lock protected) **/
-(void)setStatus:(id)status
{
  if (status!=_status)
    {
      [self lock];
      ASSIGN(_status,status);
      [self unlock];
    };
};

-(id) _status
{
  //??
  return _status;
};

/** Set the refresh interval. Default is 0. If >0, a refresh header is appended to the response **/
-(void)setRefreshInterval:(NSTimeInterval)interval
{
  if (interval>0)
    _refreshInterval = interval;
  else
    _refreshInterval = 0;
};

/** Get the refresh interval. **/
-(NSTimeInterval)refreshInterval
{
  return _refreshInterval;
};

/** Return YES if action is canceled by the user. Used to abort thread.  (Lock protected) **/
-(BOOL)isCancelled
{
  //??
  return _cancelled;
};

/** This method should be overwritten to return a result. Default implementation raise an exception
Warning: you should first increase app worker thread count. 
count=1 ==> you code don't nead to be thread safe
count>1 ==> if your code is not thread safe, you should disable concurrent request handling
count>1 ==> if your code is thread safe, you can enable concurrent request handling
**/
-(id) performAction
{
  [self subclassResponsibility:_cmd];

  return nil;
};


/** This method is call by GSWMetaRefresh -invokeAction.
It can be manually called (for example if the page does not refresh itself.
Status value make it call -pageForException:, -pageForResult:, -refreshPageForStatus: or -cancelPageForStatus:
Don't override it
**/
-(GSWComponent*)refresh
{
  //??
  GSWComponent *page=nil;
  NSException *exception=nil;
  id result=[self _result];//OK
  id status=nil;

  exception=[self _exception];
  status=[self _status];
  if (exception)
    page=[self pageForException:exception];
  else if (_done)//OK
    {
      //_keepRefreshing = NO;
      page=[self pageForResult:result];//OK
    }
  else if (_cancelled) 
    page=[self cancelPageForStatus:status];
  else
    page=[self refreshPageForStatus:status];

  return page;
};

-(GSWComponent*)cancel
{
  //??
  GSWComponent *page=nil;
  id status=nil;
  status=[self _status];

  [self _setCancelled:YES];
  page=[self cancelPageForStatus:status];

  return page;
};

/** Called when an exception occur in the process thread. Replace -pageForResult: call.
Default implemnetation raise the exception **/
-(GSWComponent *)pageForException:(NSException *)exception
{
  //??

  [exception raise];//??

  return nil;
};


/** Called when the process thread is done.
Default implementation stops automatic refresh and returns self.
You can override this to return a newly created result page
**/
-(GSWComponent *)pageForResult:(id) result
{
  //TODO: stop refreshing ?
  _done=YES;

  return self;
};

/** Called on each refresh. Should return self. **/
-(GSWComponent *)refreshPageForStatus:(id) status
{
  return self;
};

/** Called when the process thread is cancelled. Replace -pageForResult: call.
Default implementation stops automatic refresh and returns self.
**/
-(GSWComponent *)cancelPageForStatus:(id) status;
{
  //[self subclassResponsibility: _cmd];
  _cancelled=YES;

  return self;
};


-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                            inContext:(GSWContext*)aContext
{
  //??
  GSWElement *element=nil;

  if ([GSWContext_senderID(aContext) isEqualToString:@"GSWMetaRefresh"])//GSWMetaRefreshSenderId])//senderID ret: GSWMetaRefresh // Seems OK
    {
      element=[self refresh];//OK
    }
  else
    element=[super invokeActionForRequest:aRequest
                   inContext:aContext];

  return element;
};


-(void) _setCancelled:(BOOL)cancelled
{
  //??
  if (cancelled!=_cancelled)
    {
      [self lock];
      _cancelled=cancelled;
      [self unlock];      
    };
};

-(void) _setResult:(id)result
{
  if (result!=_result)
    {
      [self lock];
      _result=result;
      [self unlock];      
    };
};

-(id)_result
{
  return _result;
};

-(void)_setException:(NSException*)exception
{
//??
  if (exception!=_exception)
    {
      [self lock];
      _exception=exception;
      [self unlock];
    };
  [self subclassResponsibility: _cmd];
};

-(NSException*)_exception
{
  return _exception;
};



@end

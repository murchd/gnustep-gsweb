/* GSWLoadBalancing.c - GSWeb: Adaptors: Load Balancing
   Copyright (C) 1999, 2000, 2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 	July 1999
   
   This file is part of the GNUstep Web Library.
   
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
*/

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <sys/param.h>

#include "config.h"
#include "GSWUtil.h"
#include "GSWDict.h"
#include "GSWList.h"
#include "GSWString.h"
#include "GSWURLUtil.h"
#include "GSWConfig.h"
#include "GSWAppRequestStruct.h"
#include "GSWAppConnect.h"
#include "GSWHTTPRequest.h"
#include "GSWHTTPResponse.h"
#include "GSWAppRequest.h"
#include "GSWHTTPHeaders.h"
#include "GSWLoadBalancing.h"
#include "GSWLock.h"
#include "GSWApp.h"

//--------------------------------------------------------------------
BOOL
GSWLoadBalancing_FindApp(GSWAppRequest    *p_pAppRequest,
			 void             *p_pLogServerData,
			 GSWURLComponents *p_pURLComponents)
{
  BOOL fFound=FALSE;
  GSWApp *pApp=NULL;
  GSWLog(GSW_DEBUG,p_pLogServerData,"Start GSWLoadBalancing_FindApp");
  GSWLog(GSW_INFO,p_pLogServerData,"LoadBalance: looking for %s",
		   p_pAppRequest->pszName);
  GSWConfig_LoadConfiguration(p_pLogServerData);
  GSWLock_Lock(g_lockAppList);
  pApp = GSWConfig_GetApp(p_pAppRequest->pszName);
  if (pApp)
    {
      GSWList *pInstancesList=GSWDict_AllKeys(&pApp->stInstancesDict);
      unsigned int uInstancesCount=GSWList_Count(pInstancesList);
      int iTries=uInstancesCount;
      GSWAppInstance *pAppInstance=NULL;
      time_t curTime = (time_t)0;
	  
      while (!fFound && iTries-->0)
	{
	  pApp->iIndex = (pApp->iIndex+1) % uInstancesCount;
	  pAppInstance =
	    (GSWAppInstance *)GSWDict_ValueForKey(&pApp->stInstancesDict,
			  GSWList_ElementAtIndex(pInstancesList,pApp->iIndex));
	  if (pAppInstance)
	    {
	      if (!pAppInstance->pApp)
		{
		  GSWLog(GSW_CRITICAL,p_pLogServerData,
			 "AppInstance pApp is null pAppInstance=%p",
			 pAppInstance);
		};
	      if (pAppInstance->timeNextRetryTime!=0)
		{
		  if (!curTime)
		    time(&curTime);
		  if (pAppInstance->timeNextRetryTime<curTime)
		    {
		      GSWLog(GSW_CRITICAL,
			     p_pLogServerData,
  "LoadBalance: Instance %s:%d was marked dead for %d secs. Now resurecting !",
			     p_pAppRequest->pszName, 
			     pAppInstance->iInstance,
			     APP_CONNECT_RETRY_DELAY);
		      pAppInstance->timeNextRetryTime=0;
		    };
		};
	      if (pAppInstance->timeNextRetryTime==0 && pAppInstance->fValid)
		{
		  BOOL okay = TRUE;
		  // check if refused, time to try again ?
		  if (p_pURLComponents->stRequestHandlerKey.iLength==0 ||
		      p_pURLComponents->stRequestHandlerKey.pszStart==NULL)
		    {
		      GSWAppInfo *thisAppInfo = 
			GSWAppInfo_Find(p_pAppRequest->pszName,
					pAppInstance->iInstance);
		      if (thisAppInfo && thisAppInfo->isRefused)
			{
			  time_t actTime = (time_t)0;
			  // this instance refuses new sessions
			  time(&actTime);
			  if (actTime > thisAppInfo->timeNextRetryTime)
			    {
			      thisAppInfo->isRefused = FALSE;	// try it again
			    }
			  else
			    {
			      okay = FALSE;	// try an other instance
			    }
			}
		    }
		  
		  if (okay == TRUE)
		    {
		      fFound = TRUE;
		      strcpy(p_pAppRequest->pszName,pApp->pszName);
		      p_pAppRequest->iInstance = pAppInstance->iInstance;
		      p_pAppRequest->pszHost = pAppInstance->pszHostName;
		      p_pAppRequest->iPort = pAppInstance->iPort;
		      p_pAppRequest->eType = EAppType_LoadBalanced;
		      p_pAppRequest->pAppInstance = pAppInstance;
		      pAppInstance->uOpenedRequestsNb++;
		    }
		};
	    };
	};
      GSWList_Free(pInstancesList,FALSE);
    };
  GSWLock_Unlock(g_lockAppList);
  
  if (fFound)
    GSWLog(GSW_INFO,p_pLogServerData,
	   "LoadBalance: looking for %s, fFound instance %d on %s:%d",
	   p_pAppRequest->pszName,
	   p_pAppRequest->iInstance,
	   p_pAppRequest->pszHost,
	   p_pAppRequest->iPort);
  else
    GSWLog(GSW_INFO,p_pLogServerData,"LoadBalance: looking for %s, Not Found",
	   p_pAppRequest->pszName);
  GSWLog(GSW_DEBUG,p_pLogServerData,"Stop GSWLoadBalancing_FindApp");
  return fFound;
};

//--------------------------------------------------------------------
BOOL
GSWLoadBalancing_FindInstance(GSWAppRequest    *p_pAppRequest,
			      void             *p_pLogServerData,
			      GSWURLComponents *p_pURLComponents)
{
  BOOL fFound=FALSE;
  GSWApp *pApp=NULL;
  int i=0;
  GSWLog(GSW_DEBUG,p_pLogServerData,"Start GSWLoadBalancing_FindInstance");
  GSWConfig_LoadConfiguration(p_pLogServerData);
  GSWLock_Lock(g_lockAppList);
  pApp = (GSWApp *)GSWConfig_GetApp(p_pAppRequest->pszName);
  if (pApp)
    {
      GSWAppInstance *pAppInstance=NULL;
      char szInstanceNum[50]="";
      sprintf(szInstanceNum,"%d",p_pAppRequest->iInstance);
      pAppInstance =
	(GSWAppInstance *)GSWDict_ValueForKey(&pApp->stInstancesDict,
					      szInstanceNum);
      if (pAppInstance)
	{
	  GSWLog(GSW_DEBUG,p_pLogServerData,"Instance Found");
	  if (pAppInstance->fValid)
	    {
	      BOOL okay = TRUE;
	      // check if refused, time to try again ?
	      if (p_pURLComponents->stRequestHandlerKey.iLength==0 ||
		  p_pURLComponents->stRequestHandlerKey.pszStart==NULL)
		{
		  GSWAppInfo *thisAppInfo =
		    GSWAppInfo_Find(p_pAppRequest->pszName,
				    pAppInstance->iInstance);
		  if (thisAppInfo && thisAppInfo->isRefused)
		    {
		      time_t actTime = (time_t)0;
		      // this instance refuses new sessions
		      time(&actTime);
		      if (actTime > thisAppInfo->timeNextRetryTime)
			{
			  thisAppInfo->isRefused = FALSE;	// try it again
			}
		      else
			{
			  okay = FALSE;	// try an other instance
			}
		    }
		}
	      
	      if (okay == TRUE)
		{
		  fFound=TRUE;
		  p_pAppRequest->iInstance = pAppInstance->iInstance;
		  p_pAppRequest->pszHost = pAppInstance->pszHostName;
		  p_pAppRequest->iPort = pAppInstance->iPort;
		  p_pAppRequest->eType = EAppType_LoadBalanced;
		  p_pAppRequest->pAppInstance = pAppInstance;
		  pAppInstance->uOpenedRequestsNb++;		
		  GSWLog(GSW_DEBUG,p_pLogServerData,"Instance is valid");
		}
	    }
	  else
	    {
	      GSWLog(GSW_DEBUG,p_pLogServerData,"Instance is not valid");
	    };
	};
    };
  GSWLock_Unlock(g_lockAppList);
  GSWLog(GSW_DEBUG,p_pLogServerData,"Stop GSWLoadBalancing_FindInstance");
  return fFound;
};

//--------------------------------------------------------------------
void
GSWLoadBalancing_MarkNotRespondingApp(GSWAppRequest *p_pAppRequest,
				      void          *p_pLogServerData)
{
  GSWAppInstance *pAppInstance;
  time_t now;
  time(&now);
  pAppInstance = p_pAppRequest->pAppInstance;
  pAppInstance->uOpenedRequestsNb--;
  pAppInstance->timeNextRetryTime=now+APP_CONNECT_RETRY_DELAY;
  GSWLog(GSW_WARNING,p_pLogServerData,"Marking %s unresponsive",
	 p_pAppRequest->pszName);
  if (!pAppInstance->fValid)
    {
      if (GSWAppInstance_FreeIFND(pAppInstance))
	pAppInstance=NULL;
    };
};

//--------------------------------------------------------------------
void
GSWLoadBalancing_StartAppRequest(GSWAppRequest *p_pAppRequest,
				 void          *p_pLogServerData)
{
  GSWAppInstance *pAppInstance=p_pAppRequest->pAppInstance;
  if (pAppInstance->timeNextRetryTime!=0)
    {
      pAppInstance->timeNextRetryTime=0;
      GSWLog(GSW_WARNING,p_pLogServerData,
	     "Marking %s as alive",p_pAppRequest->pszName);
    };
}

//--------------------------------------------------------------------
void
GSWLoadBalancing_StopAppRequest(GSWAppRequest *p_pAppRequest,
				void          *p_pLogServerData)
{
  GSWAppInstance *pAppInstance=p_pAppRequest->pAppInstance;
  GSWLock_Lock(g_lockAppList);
  pAppInstance->uOpenedRequestsNb--;
  if (!pAppInstance->fValid)
    {
      if (GSWAppInstance_FreeIFND(pAppInstance))
	pAppInstance=NULL;
    };
  GSWLock_Unlock(g_lockAppList);
  p_pAppRequest->pAppInstance = NULL;
};


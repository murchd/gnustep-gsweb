/* GSWExceptionPage.h - GSWeb: Class GSWExceptionPage
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Apr 1999
   
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

#ifndef _GSWExceptionPage_h__
	#define _GSWExceptionPage_h__


//==============================================================================
@interface GSWExceptionPage: GSWComponent
{
  NSString* tmpReason;
  
  NSString* tmpUserInfoKey;
  NSString* tmpUserInfoValue;

  NSException* exception;
  NSArray* reasons;
};

-(void)dealloc;
-(NSArray*)getReasons;
-(void)appendToResponse:(GSWResponse*)response_
			  inContext:(GSWContext*)context_;
-(void)setException:(NSException*)exception_;
@end

#endif // _GSWExceptionPage_h__


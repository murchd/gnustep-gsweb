/** GSWFileUploadFormComponent.m - <title>GSWeb: Class GSWFileUploadFormComponent</title>

   Copyright (C) 1999-2003 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date:        Dec 1999
   
   $Revision$
   $Date$
   
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

#include "GSWExtGSWWOCompatibility.h"
#include "GSWFileUploadFormComponent.h"
//====================================================================
@implementation GSWFileUploadFormComponent

//--------------------------------------------------------------------
-(id)init
{
  if ((self=[super init]))
	{
	};
  return self;
};

//--------------------------------------------------------------------
-(void)awake
{
  [super awake];
};

//--------------------------------------------------------------------
-(void)sleep
{
  [super sleep];
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_fileInfo);
  [super dealloc];
};

//--------------------------------------------------------------------
-(BOOL)synchronizesVariablesWithBindings
{
  return NO;
};

//--------------------------------------------------------------------
-(NSMutableDictionary*)fileInfo
{
  if (!_fileInfo)
	{
	  if ([self hasBinding:@"fileInfo"])
		{
		  _fileInfo=[[self valueForBinding:@"fileInfo"] mutableCopy];
                  if (!_fileInfo)
                    _fileInfo=[NSMutableDictionary new];
		};
	};

  return _fileInfo;
};

//--------------------------------------------------------------------
-(BOOL)isViewEnabled
{
  BOOL isViewEnabled=YES;
  if ([self hasBinding:@"isViewEnabled"])
    {
      id isViewEnabledObject=[self valueForBinding:@"isViewEnabled"];
      isViewEnabled=boolValueFor(isViewEnabledObject);
    };
  if (isViewEnabled)
    {
      NSMutableDictionary* fileInfo=[self fileInfo];
      isViewEnabled=([fileInfo objectForKey:@"data"]!=nil
                     || [fileInfo objectForKey:@"filePath"]!=nil
                     || [fileInfo objectForKey:@"fileURL"]!=nil);
    };
  return isViewEnabled;
};

//--------------------------------------------------------------------
-(BOOL)isDeleteEnabled
{
  BOOL isDeleteEnabled=NO;
  if ([self hasBinding:@"isDeleteEnabled"])
    {
      id isDeleteEnabledObject=[self valueForBinding:@"isDeleteEnabled"];
      isDeleteEnabled=boolValueFor(isDeleteEnabledObject);
    };
  if (isDeleteEnabled)
    {
      NSMutableDictionary* fileInfo=[self fileInfo];
      isDeleteEnabled=([fileInfo objectForKey:@"data"]!=nil
                       || [fileInfo objectForKey:@"filePath"]!=nil
                       || [fileInfo objectForKey:@"fileURL"]!=nil);
    };
  return isDeleteEnabled;
};

//--------------------------------------------------------------------
-(GSWComponent*)updateAction
{
  GSWComponent* _returnPage=nil;
  [self setValue:_fileInfo
		forBinding:@"fileInfo"];
  if ([self hasBinding:@"action"])
	{
	  _returnPage=[self valueForBinding:@"action"];
	};
  DESTROY(_fileInfo);

  return _returnPage;
};

//--------------------------------------------------------------------
-(GSWComponent*)deleteAction
{
  GSWComponent* _returnPage=nil;
  [_fileInfo removeObjectForKey:@"data"];
  [self setValue:_fileInfo
        forBinding:@"fileInfo"];
  if ([self hasBinding:@"action"])
    {
      _returnPage=[self valueForBinding:@"action"];
    };
  DESTROY(_fileInfo);

  return _returnPage;
};

@end



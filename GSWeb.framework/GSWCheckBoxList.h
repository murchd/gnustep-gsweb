/** GSWCheckBoxList.h - <title>GSWeb: Class GSWCheckBoxList</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
   $Revision$
   $Date$

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

// $Id$

#ifndef _GSWCheckBoxList_h__
	#define _GSWCheckBoxList_h__

//====================================================================
@interface GSWCheckBoxList: GSWInput
{
  GSWAssociation* _list;
  GSWAssociation* _item;
  GSWAssociation* _index;
  GSWAssociation* _selections;
  GSWAssociation* _prefix;
  GSWAssociation* _suffix;
  GSWAssociation* _displayString;
  GSWAssociation* _escapeHTML;
  GSWAssociation* _itemDisabled;
  BOOL _defaultEscapeHTML;
  BOOL _autoValue;
};

-(id)initWithName:(NSString*)name
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements;
-(void)dealloc;

-(NSString*)description;
-(NSString*)elementName;


@end

//====================================================================
@interface GSWCheckBoxList (GSWCheckBoxListA)
-(void)appendToResponse:(GSWResponse*)response
              inContext:(GSWContext*)context;

-(void)takeValuesFromRequest:(GSWRequest*)request
                   inContext:(GSWContext*)context; 

-(void)_slowTakeValuesFromRequest:(GSWRequest*)request
                        inContext:(GSWContext*)context; 

-(void)_fastTakeValuesFromRequest:(GSWRequest*)request
                        inContext:(GSWContext*)context; 
@end

//====================================================================
@interface GSWCheckBoxList (GSWCheckBoxListB)
-(void)appendGSWebObjectsAssociationsToResponse:(GSWResponse*)response
                                      inContext:(GSWContext*)context;
@end

//====================================================================
@interface GSWCheckBoxList (GSWCheckBoxListC)
-(BOOL)appendStringAtRight:(id)unkwnon
               withMapping:(char*)mapping;
-(BOOL)appendStringAtLeft:(id)unkwnon
              withMapping:(char*)mapping;
-(BOOL)compactHTMLTags;
@end


#endif //_GSWCheckBoxList_h__

/* GSWTemplateParserXML.h - GSWeb: Class GSWTemplateParserXML
   Copyright (C) 1999 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@sbuilders.com>
   Date: 		Mar 1999
   
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

// $Id$

#ifndef _GSWTemplateParserXML_h__
	#define _GSWTemplateParserXML_h__

#include "GSWTemplateParser.h"
#include <Foundation/GSXML.h>
#include <libxml/parser.h>
#include <libxml/parserInternals.h>
#include <libxml/SAX.h>
#include <libxml/HTMLparser.h>


@class GSWTemplateParser;
//====================================================================
@interface GSWTemplateParserSAXHandler : GSHTMLSAXHandler
{
  GSWTemplateParser* _templateParser;
};

+(void)lock;
+(void)unlock;
+(NSString*)cachedDTDContentForKey:(NSString*)url;
+(void)setCachedDTDContent:(NSString*)externalContent
                    forKey:(NSString*)url;
+(id)handlerWithTemplateParser:(GSWTemplateParser*)templateParser;
-(id)initWithTemplateParser:(GSWTemplateParser*)templateParser_;
-(id)init;
-(xmlParserInputPtr)resolveEntity:(NSString*)publicIdEntity
                         systemID:(NSString*)systemIdEntity;
-(void)warning:(NSString*)message;
-(void)error:(NSString*)message;
-(void)fatalError:(NSString*)message;
@end

//====================================================================
@interface GSWTemplateParserXML : GSWTemplateParser
{
  GSXMLDocument* _xmlDocument;
}

-(void)dealloc;
-(NSArray*)templateElements;
-(NSArray*)createElementsFromNode:(GSXMLNode*)node;

@end

//====================================================================
@interface GSWTemplateParserXMLHTML : GSWTemplateParserXML
{
};

@end

#endif //_GSWTemplateParserXML_h__
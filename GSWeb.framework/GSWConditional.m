/** GSWConditional.m - <title>GSWeb: Class GSWConditional</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 		Jan 1999
   
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

#include <GSWeb/GSWeb.h>

/**
Bindings

	condition	if evaluated to YES (or NO if negate evaluted to YES), the enclosed code is emitted/used

        value		if evaluated value is equal to conditionValue evaluated value, the enclosed code is 
        			emitted/used (or not equal if negate evaluated to YES);

        conditionValue	if evaluated value is equal to conditionValue evaluated value, the enclosed code is 
        			emitted/used (or not equal if negate evaluated to YES);

        negate		If evaluated to yes, negate the condition (defaut=NO)
**/

//====================================================================
@implementation GSWConditional

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)someAssociations
         template:(GSWElement*)templateElement
{
  //OK
  LOGObjectFnStart();
  if ((self=[self initWithName:aName
                  associations:someAssociations
                  contentElements:templateElement ? [NSArray arrayWithObject:templateElement] : nil]))
    {
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(id)initWithName:(NSString*)aName
     associations:(NSDictionary*)associations
  contentElements:(NSArray*)elements
{
  LOGObjectFnStart();
  if ((self=[super initWithName:aName
                   associations:nil
                   template:nil]))
    {
      if (elements)
        _childrenGroup=[[GSWHTMLStaticGroup alloc]initWithContentElements:elements];

      _condition = [[associations objectForKey:condition__Key
                                  withDefaultObject:[_condition autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWConditional condition=%@",_condition);

      if (!WOStrictFlag)
        {
          _value = [[associations objectForKey:value__Key
                                  withDefaultObject:[_value autorelease]] retain];
          NSDebugMLLog(@"gswdync",@"GSWConditional value=%@",_value);
          
          _conditionValue  = [[associations objectForKey:conditionValue__Key
                                            withDefaultObject:[_conditionValue autorelease]] retain];
          NSDebugMLLog(@"gswdync",@"GSWConditional conditionValue=%@",_conditionValue);
          
          if (_conditionValue && !_value)
            ExceptionRaise0(@"GSWConditional",
                            @"'conditionValue' parameter need 'value' parameter");
          
          if (_value && !_conditionValue)
            ExceptionRaise0(@"GSWConditional",
                            @"'value' parameter need 'conditionValue' parameter");
          
          if (_conditionValue && _condition)
            ExceptionRaise0(@"GSWConditional",
                            @"You can't have 'condition' parameter with 'value' and 'conditionValue' parameters");
        };
      _negate = [[associations objectForKey:negate__Key
                               withDefaultObject:[_negate autorelease]] retain];
      NSDebugMLLog(@"gswdync",@"GSWConditional negate=%@",_negate);
    };
  LOGObjectFnStop();
  return self;
};

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_condition);
  DESTROY(_value);
//GSWeb Additions {
  DESTROY(_conditionValue);
  DESTROY(_negate);
// }
  DESTROY(_childrenGroup);
  [super dealloc];
}

//--------------------------------------------------------------------
-(void)setDefinitionName:(NSString*)definitionName
{
  [super setDefinitionName:definitionName];
  if (definitionName && _childrenGroup)
    [_childrenGroup setDefinitionName:[NSString stringWithFormat:@"%@-StaticGroup",definitionName]];
};

//--------------------------------------------------------------------
-(NSString*)description
{
  return [NSString stringWithFormat:@"<%s %p>",
				   object_get_class_name(self),
				   (void*)self];
};

//====================================================================
@implementation GSWConditional (GSWConditionalA)

//--------------------------------------------------------------------
-(void)takeValuesFromRequest:(GSWRequest*)aRequest
                   inContext:(GSWContext*)aContext
{
  //OK
  BOOL condition=NO;
  BOOL negate=NO;
  BOOL doIt=NO;
  LOGObjectFnStart();
  GSWStartElement(aContext);
  GSWAssertCorrectElementID(aContext);
  if (!WOStrictFlag && _conditionValue)
    {
      GSWComponent* component=[aContext component];
      id conditionValueValue=[_conditionValue valueInComponent:component];
      id valueValue=[_value valueInComponent:component];
      NSDebugMLog(@"_conditionValue=%@ conditionValueValue=%@",
                  _conditionValue,conditionValueValue);
      NSDebugMLog(@"_value=%@ valueValue=%@",
                  _value,valueValue);
      condition=SBIsValueEqual(conditionValueValue,valueValue);
    }
  else    
    condition=[self evaluateCondition:_condition
                    inContext:aContext];

  negate=[self evaluateCondition:_negate
               inContext:aContext];
  doIt=condition;
  NSDebugMLLog(@"gswdync",@"elementID=%@",[aContext elementID]);
  if (negate)
    doIt=!doIt;
  NSDebugMLLog(@"gswdync",@"defname=%@ condition=%@ negate=%@ evaluatedCondition=%s evaluatedNegate=%s doIt=%s",
               [self definitionName],
               _condition,
               _negate,
               (condition ? "YES" : "NO"),
               (negate ? "YES" : "NO"),
               (doIt ? "YES" : "NO"));
  if (doIt)
    {
      GSWRequest* _request=[aContext request];
      BOOL isFromClientComponent=[_request isFromClientComponent];
      [aContext appendZeroElementIDComponent];
      [_childrenGroup takeValuesFromRequest:aRequest
                     inContext:aContext];
      [aContext deleteLastElementIDComponent];
    };
  GSWStopElement(aContext);
  GSWAssertIsElementID(aContext);
  LOGObjectFnStop();
};

//--------------------------------------------------------------------
-(GSWElement*)invokeActionForRequest:(GSWRequest*)aRequest
                           inContext:(GSWContext*)aContext
{
  //OK
  GSWElement* element=nil;
  BOOL condition=NO;
  BOOL negate=NO;
  BOOL doIt=NO;
  LOGObjectFnStart();
  GSWStartElement(aContext);
  GSWAssertCorrectElementID(aContext);
  if (!WOStrictFlag && _conditionValue)
    {
      GSWComponent* component=[aContext component];
      id conditionValueValue=[_conditionValue valueInComponent:component];
      id valueValue=[_value valueInComponent:component];
      NSDebugMLog(@"_conditionValue=%@ conditionValueValue=%@",
                  _conditionValue,conditionValueValue);
      NSDebugMLog(@"_value=%@ valueValue=%@",
                  _value,valueValue);
      condition=SBIsValueEqual(conditionValueValue,valueValue);
    }
  else    
    condition=[self evaluateCondition:_condition
                    inContext:aContext];

  negate=[self evaluateCondition:_negate
               inContext:aContext];
  doIt=condition;
  if (negate)
    doIt=!doIt;
  NSDebugMLLog(@"gswdync",@"defname=%@ condition=%@ negate=%@ evaluatedCondition=%s evaluatedNegate=%s doIt=%s",
               [self definitionName],
               _condition,
               _negate,
               (condition ? "YES" : "NO"),
               (negate ? "YES" : "NO"),
               (doIt ? "YES" : "NO"));
  if (doIt)
    {
      GSWRequest* request=[aContext request];
      BOOL isFromClientComponent=[request isFromClientComponent];
      [aContext appendZeroElementIDComponent];
      NSDebugMLLog(@"gswdync",@"childrenGroup=%@",_childrenGroup);
      element=[_childrenGroup invokeActionForRequest:aRequest
                             inContext:aContext];
      NSDebugMLLog(@"gswdync",@"element=%@",element);
      [aContext deleteLastElementIDComponent];
    };
  GSWStopElement(aContext);
  GSWAssertIsElementID(aContext);
  LOGObjectFnStop();
  return element;
};

//--------------------------------------------------------------------
-(void)appendToResponse:(GSWResponse*)aResponse
              inContext:(GSWContext*)aContext
{
  //OK
  BOOL condition=NO;
  BOOL negate=NO;
  BOOL doIt=NO;
  LOGObjectFnStart();
  GSWStartElement(aContext);
  GSWSaveAppendToResponseElementID(aContext);

  if (!WOStrictFlag && _conditionValue)
    {
      GSWComponent* component=[aContext component];
      id conditionValueValue=[_conditionValue valueInComponent:component];
      id valueValue=[_value valueInComponent:component];
      NSDebugMLog(@"_conditionValue=%@ conditionValueValue=%@",
                  _conditionValue,conditionValueValue);
      NSDebugMLog(@"_value=%@ valueValue=%@",
                  _value,valueValue);
      condition=SBIsValueEqual(conditionValueValue,valueValue);
    }
  else    
    condition=[self evaluateCondition:_condition
                    inContext:aContext];
  NSDebugMLLog(@"gswdync",@"condition=%s",condition ? "YES" : "NO");
  negate=[self evaluateCondition:_negate
               inContext:aContext];
  NSDebugMLLog(@"gswdync",@"negate=%s",negate ? "YES" : "NO");
  doIt=condition;
  if (negate)
    doIt=!doIt;
  NSDebugMLLog(@"gswdync",@"defname=%@ condition=%@ negate=%@ evaluatedCondition=%s evaluatedNegate=%s doIt=%s",
               [self definitionName],
               _condition,
               _negate,
               (condition ? "YES" : "NO"),
               (negate ? "YES" : "NO"),
               (doIt ? "YES" : "NO"));
  if (doIt)
    {
      GSWRequest* request=[aContext request];
      BOOL isFromClientComponent=[request isFromClientComponent];
      [aContext appendZeroElementIDComponent];
      [_childrenGroup appendToResponse:aResponse
                      inContext:aContext];
      [aContext deleteLastElementIDComponent];
    };
  GSWStopElement(aContext);
  GSWAssertIsElementID(aContext);
  LOGObjectFnStop();
};

@end

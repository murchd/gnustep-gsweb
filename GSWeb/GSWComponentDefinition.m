/** GSWComponentDefinition.m - <title>GSWeb: Class GSWComponentDefinition</title>

   Copyright (C) 1999-2002 Free Software Foundation, Inc.
   
   Written by:	Manuel Guesdon <mguesdon@orange-concept.com>
   Date: 	Jan 1999
   
   $Revision$
   $Date$
   $Id$

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

#include "GSWeb.h"
#include <GNUstepBase/NSObject+GNUstepBase.h>
#include <GNUstepBase/GSMime.h>

//====================================================================

/* Static variables */

static NSLock *       ComponentConstructorLock;
static NSLock *       TemplateLock;
static GSWContext *   TheTemporaryContext;

@implementation GSWComponentDefinition

+ (void) initialize
{
  if (self == [GSWComponentDefinition class]) {
    ComponentConstructorLock = [[NSLock alloc] init];
    TemplateLock = [[NSLock alloc] init];
    TheTemporaryContext = nil; 
  }
}

// that Method is used INTERNAL.
+ (GSWContext *) TheTemporaryContext
{
  return TheTemporaryContext;
}

//--------------------------------------------------------------------

// CHECKME: missing Languages?
// we my have a different name and class?
//  aName StartPage
//  aPath   /Users/dave/projects/new/PBXBilling/trunk/PBX.gswa/Resources/StartPage.wo
//  baseURL /WebObjects/PBX.gswa/Resources/StartPage.wo

-(id)initWithName:(NSString*)aName
             path:(NSString*)aPath
          baseURL:(NSString*)baseURL
    frameworkName:(NSString*)aFrameworkName
{
  NSString * myBasePath = nil;
  NSFileManager * defaultFileManager = nil;

  [super init];
  ASSIGN(_name, [aName stringByDeletingPathExtension]);    // does it ever happen that
  ASSIGN(_className, aName);                               // those are different? dw.
  _componentClass = NSClassFromString(_className);  
  ASSIGN(_path, aPath);   
  ASSIGN(_url, baseURL);   
  ASSIGN(_frameworkName, aFrameworkName);   
  DESTROY(_language);
  DESTROY(_wooReadDate);
  DESTROY(_htmlReadDate);
  _hasBeenAccessed = NO;
  _hasContextConstructor = NO;
  _isStateless = NO;
  DESTROY(_instancePool);
  _instancePool = [NSMutableArray new];
  _lockInstancePool = [GSWApp isConcurrentRequestHandlingEnabled];

  if ((_name != nil) && (_frameworkName != nil)) {
    _componentClass = NSClassFromString(_className);
  }
  myBasePath = [aPath stringByAppendingPathComponent: aName];
  ASSIGN(_htmlPath,[myBasePath stringByAppendingPathExtension:@"html"]);
  ASSIGN(_wodPath,[myBasePath stringByAppendingPathExtension:GSWComponentDeclarationsSuffix[GSWebNamingConv]]);
  ASSIGN(_wooPath,[myBasePath stringByAppendingPathExtension:GSWArchiveSuffix[GSWebNamingConv]]);

  defaultFileManager = [NSFileManager defaultManager];
  
  if (_componentClass == Nil) {
    [self autorelease];
    NSLog(@"%s: No component class for component named '%@' found", __PRETTY_FUNCTION__, _name);
    return nil;
  }

//  if (([defaultFileManager fileExistsAtPath: _htmlPath] == NO) ||
//      ([defaultFileManager fileExistsAtPath: _wodPath] == NO) ||
//      ([defaultFileManager fileExistsAtPath: _wooPath] == NO) ||
//      (_componentClass == Nil)) {
//
//      [NSException raise:NSInvalidArgumentException
//                  format:@"%s: No template found for component named '%@'",
//                         __PRETTY_FUNCTION__, _name];
//  }
  _archive = nil;
  _encoding = 0;  // to test for real value later
  _template = nil;
  [self setCachingEnabled:[[GSWApp class] isCachingEnabled]];
  _isAwake = NO;

  _instancePoolLock = [[NSLock alloc] init];
  
  return self;
}

//--------------------------------------------------------------------
-(void)dealloc
{
  DESTROY(_name);
  DESTROY(_path);
  DESTROY(_url);
  DESTROY(_frameworkName);
  DESTROY(_language);
  DESTROY(_className);
  _componentClass = Nil;
  DESTROY(_template);
  DESTROY(_htmlPath);
  DESTROY(_wodPath);
  DESTROY(_wooPath);
  DESTROY(_archive);
  DESTROY(_sharedInstance);
  DESTROY(_instancePool);
  
  DESTROY(_wooReadDate);
  DESTROY(_htmlReadDate);

  
  [super dealloc];

};


//--------------------------------------------------------------------

- (void) checkInComponentInstance:(GSWComponent*) component
{
  if (_sharedInstance == nil)
  {
    _sharedInstance = component;
  } else
  {
    [_instancePool addObject:component];
  }
}

- (void) _checkInComponentInstance:(GSWComponent*) component
{
  BOOL locked = NO;
  
  if (_lockInstancePool) {
    NS_DURING
      [_instancePoolLock lock];
        locked = YES;
        [self checkInComponentInstance: component];
        locked = NO;
      [_instancePoolLock unlock];    

    NS_HANDLER
     if (locked) {
        [_instancePoolLock unlock];     
     }
     localException=[localException exceptionByAddingUserInfoFrameInfoFormat:@"In %s",
                                                                              __PRETTY_FUNCTION__];
     [localException raise];
    NS_ENDHANDLER;

  } else {
      [self checkInComponentInstance: component];
  }
}

//--------------------------------------------------------------------
-(NSString*)frameworkName
{
  return _frameworkName;
};

//--------------------------------------------------------------------
-(NSString*)baseURL
{
  return _url;
}

//--------------------------------------------------------------------
-(NSString*)path
{
  return _path;
};

//--------------------------------------------------------------------
-(NSString*)name
{
  return _name;
};

//--------------------------------------------------------------------
-(NSString*)description
{
  //TODO
  return [NSString stringWithFormat:@"<%s %p - name:[%@] frameworkName=[%@] componentClass=[%@] isCachingEnabled=[%s] isAwake=[%s]>",
				   __FILE__,
				   (void*)self,
				   _name,
				   _frameworkName,
				   _componentClass,
				   _caching ? "YES" : "NO",
				   _isAwake ? "YES" : "NO"];
};

//--------------------------------------------------------------------
-(void)sleep
{
  //OK
  _isAwake=NO;
};

//--------------------------------------------------------------------
// dw
-(void)awake
{
  if (!_isAwake) {
    _isAwake = YES;
    if (! _caching) {
      [self componentClass];
    }
  }
};


//--------------------------------------------------------------------
-(BOOL)isCachingEnabled
{
  return _caching;
};

//--------------------------------------------------------------------
-(void)setCachingEnabled:(BOOL)flag
{
  _caching = flag;
};


//--------------------------------------------------------------------
-(void)_clearCache
{
}

// CHECKME

-(GSWComponent*) _componentInstanceInContext:(GSWContext*) aContext
{
  Class myClass = [self componentClass];
  GSWComponent * component = nil;
  IMP           instanceInitIMP = NULL;
  IMP           componentInitIMP = NULL;
  GSWComponent * myInstance = nil;
  BOOL         locked = NO;
  
  if ([myClass isSubclassOfClass: [GSWComponent class]]) {
    [aContext _setComponentName:_className];
  }
  [aContext _setTempComponentDefinition:self];

  NS_DURING

    if (!_hasBeenAccessed) {
        myInstance = [myClass alloc];
        instanceInitIMP = [myInstance methodForSelector:@selector(init)];
        componentInitIMP = [GSWComponent instanceMethodForSelector:@selector(init)];
  
        if (instanceInitIMP != componentInitIMP) {
//          NSLog(@"Class %s should implement initWithContext: and not init", object_getClassName(myClass));
          [ComponentConstructorLock lock];
            locked = YES;
            TheTemporaryContext = aContext;
            component = AUTORELEASE([myInstance init]);
            TheTemporaryContext = nil;          
            locked = NO;
            _hasContextConstructor = NO;
          [ComponentConstructorLock unlock];
        } else {     
          component = AUTORELEASE([myInstance initWithContext: aContext]);
          _hasContextConstructor = YES;
        }
    } else {
    // check if we can use some intelligent caching here. 
        myInstance = [myClass alloc];
  
        if (_hasContextConstructor == NO) {
          [ComponentConstructorLock lock];
            locked = YES;
            TheTemporaryContext = aContext;
            component = AUTORELEASE([myInstance init]);
            TheTemporaryContext = nil;          
            locked = NO;
          [ComponentConstructorLock unlock];
        } else {     
          component = AUTORELEASE([myInstance initWithContext: aContext]);
        }
    }
  NS_HANDLER
      if (locked) {
         [ComponentConstructorLock unlock];     
      }
      localException=[localException exceptionByAddingUserInfoFrameInfoFormat:@"In %s",
                                                                            __PRETTY_FUNCTION__];
      [localException raise];
  NS_ENDHANDLER;
  
  if ([component context] == nil) {
      [NSException raise:NSInvalidArgumentException
                format:@"Component '%@' was not properly initialized. Make sure [super initWithContext:] is called. In %s",
                        _className,
                        __PRETTY_FUNCTION__];
  }
  return component;
}

- (BOOL) isStateless
{
  return _isStateless;
}


// this is called when we are already holding a lock.

-(GSWComponent*) _sharedInstanceInContext:(GSWContext*)aContext
{
  GSWComponent * component = nil;
  
  if (_sharedInstance != nil) {
    component = _sharedInstance;
    _sharedInstance = nil;
  } else {
    if ([_instancePool count] > 0) {
      component = AUTORELEASE(RETAIN([_instancePool lastObject]));
      [_instancePool removeLastObject];
    } else {
      component = [self _componentInstanceInContext:aContext];
    }
  }
  return component;
}


//--------------------------------------------------------------------
-(GSWComponent*)componentInstanceInContext:(GSWContext*)aContext
{
  GSWComponent* component=nil;
  BOOL          locked = NO;

  if (aContext == nil) {
    [NSException raise:NSInvalidArgumentException
                format:@"Attempt to create component instance without a context. In %s",
                       __PRETTY_FUNCTION__];
  }

  NS_DURING

   if (!_hasBeenAccessed) {
     component = [self _componentInstanceInContext: aContext];
     _isStateless = [component isStateless];
     _hasBeenAccessed = YES;
   } else {
     if (_isStateless) {
       if (_lockInstancePool) {
        [_instancePoolLock lock];
           locked = YES;
           component = [self _sharedInstanceInContext:aContext];
           locked = NO;        
        [_instancePoolLock unlock];
       } else {
         component = [self _sharedInstanceInContext:aContext];
       }
     } else {
       component = [self _componentInstanceInContext:aContext];
     }
   }

  NS_HANDLER

   localException=[localException exceptionByAddingUserInfoFrameInfoFormat:@"In %s",
                                                                    __PRETTY_FUNCTION__];
   if (_lockInstancePool && locked) {
     [_instancePoolLock unlock];
   }
   [localException raise];

  NS_ENDHANDLER;
   
   return component;
}


//--------------------------------------------------------------------
/** Find the class of the component **/
-(Class) componentClass
{  
  Class componentClass = Nil;
  
  if (_componentClass) {
    return _componentClass;
  }
  
  componentClass = _componentClass;
  if (!componentClass) {
    componentClass=NSClassFromString(_name);//???
  }
  if (!componentClass) // There's no class with that name
    {
      BOOL createClassesOk=NO;
      NSString* superClassName=nil;
      // If we haven't found a superclass, use GSWComponent as the superclass
      if (!superClassName)
        superClassName=@"WOComponent";
      // Create class
      createClassesOk=[GSWApplication createUnknownComponentClasses:[NSArray arrayWithObject:_name]
                                      superClassName:superClassName];

      // Use it
      componentClass=NSClassFromString(_name);
    };
  //call GSWApp isCaching
  _componentClass=componentClass;

  return componentClass;
};

//--------------------------------------------------------------------
-(GSWComponentReference*)componentReferenceWithAssociations:(NSDictionary*)associations
                                                   template:(GSWElement*)template
{
  //OK
  GSWComponentReference* componentReference=nil;
  componentReference=[[[GSWComponentReference alloc]initWithName:_name
                                                    associations:associations
                                                    template:template] autorelease];
  return componentReference;
};


//--------------------------------------------------------------------
-(void) finishInitializingComponent:(GSWComponent*)component
{
  NSDictionary * archive=nil;
  NSBundle     * bundle = [NSBundle bundleForClass:NSClassFromString(_className)];
    
  archive = [self archive];
  
  if (archive) {
    [bundle initializeObject:component
                 fromArchive:archive];
  }
}


//--------------------------------------------------------------------
-(void)_notifyObserversForDyingComponent:(GSWComponent*)aComponent
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------
-(void)_awakeObserversForComponent:(GSWComponent*)aComponent
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------
-(void)_deallocForComponent:(GSWComponent*)aComponent
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------
-(void)_awakeForComponent:(GSWComponent*)aComponent
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------
-(void)_registerObserver:(id)observer
{
  [self notImplemented: _cmd];	//TODOFN
};

//--------------------------------------------------------------------
+(void)_registerObserver:(id)observer
{
  [self notImplemented: _cmd];	//TODOFN
};

/*
 * returns the contents of the .woo
 */
- (NSDictionary *) archive
{
  if ((_caching) && (_archive)) {
    // nothing to waste time with.
    return _archive;
  } else {  
    NSFileManager * defaultManager = [NSFileManager defaultManager];
    NSDictionary  * attributes;
    NSDate        * modDate;
    
    attributes = [defaultManager attributesOfItemAtPath:_wooPath error:NULL];
    modDate = [attributes fileModificationDate];
    
    
    // file not found.
    if (!modDate) {
      modDate = [NSDate date];
      ASSIGN(_wooReadDate, modDate);
      ASSIGN(_archive, [NSDictionary dictionary]);
      return _archive;
    }
    
    if ((!_wooReadDate) || (([modDate compare:_wooReadDate] == NSOrderedDescending))) {
      ASSIGN(_wooReadDate, [NSDate date]);
      ASSIGN(_archive, [NSDictionary dictionaryWithContentsOfFile:_wooPath]);
    }
  }
  
  return _archive;  
}


-(NSStringEncoding) encoding
{
  NSDictionary     * archive = nil;
  NSString         * encodingName = nil;
  
  if ((_encoding == 0)) {
    
    _encoding = [GSWMessage defaultEncoding]; // safer, because we may not have a .woo file
    
    archive = [self archive];
    if (archive)
    {
      encodingName = [archive objectForKey:@"encoding"];
      if (encodingName)
      {
        _encoding = [GSMimeDocument encodingFromCharset:encodingName];
        
        if ((_encoding == 0)) {
          [NSException raise: NSInvalidArgumentException
                      format: @"%s %@ -- unknown encoding '%@'",__PRETTY_FUNCTION__, _wooPath, encodingName];
        }
        
      }
    }
  }
  
  return _encoding;
}

- (GSWElement *) _lockedTemplate
{
  //OK
  GSWElement* template=nil;
  NSStringEncoding encoding = [self encoding];
  
  NSString* pageDefString=nil;
  NSString* htmlString = [NSString stringWithContentsOfFile:_htmlPath 
                                                   encoding:encoding];
  
  if (!htmlString)
  {
    [NSException raise:NSInvalidArgumentException
                format:@"%s: No HTML file found at '%@'",
     __PRETTY_FUNCTION__, _htmlPath];
  } 
  
  pageDefString = [NSString stringWithContentsOfFile:_wodPath 
                                            encoding:encoding];
  
  if (!pageDefString) {
    [NSException raise:NSInvalidArgumentException
                format:@"%s: No WOD file found at '%@'",
     __PRETTY_FUNCTION__, _wodPath];
  }
  
  NS_DURING
  {
    template=[GSWTemplateParser templateNamed:_name
                             inFrameworkNamed:nil
                               withParserType:GSWTemplateParserType_Default
                              parserClassName:nil
                                   withString:htmlString
                                     encoding:encoding
                                     fromPath:nil
                           declarationsString:pageDefString
                                    languages:nil
                             declarationsPath:nil];
  }
  NS_HANDLER
  {
    localException=ExceptionByAddingUserInfoObjectFrameInfo0(localException,
                                                             @"In template Parsing");
    [localException raise];
  }
  NS_ENDHANDLER;
  
  return template;
}

- (GSWElement *) template
{
  BOOL htmlChangedOnDisk = NO;
  
  // _htmlReadDate
  if (_caching == NO) {
    htmlChangedOnDisk = YES;
  } else {
    NSFileManager * defaultManager = [NSFileManager defaultManager];
    NSDictionary  * attributes;
    NSDate        * modDate;
    
    attributes = [defaultManager attributesOfItemAtPath:_wooPath error:NULL];
    modDate = [attributes fileModificationDate];
    
    if ((!_htmlReadDate) || (([modDate compare:_htmlReadDate] == NSOrderedDescending))) {
      htmlChangedOnDisk = YES;
    } else {
      attributes = [defaultManager attributesOfItemAtPath:_wodPath error:NULL];
      modDate = [attributes fileModificationDate];
      
      if (([modDate compare:_htmlReadDate] == NSOrderedDescending)) {
        htmlChangedOnDisk = YES;
      }
    }
  }
  
  if (_htmlPath != nil && (_template == nil || htmlChangedOnDisk)) {
    ASSIGN(_htmlReadDate, [NSDate date]);
    NS_DURING
    [TemplateLock lock];
    DESTROY(_template);
    
    _template = RETAIN([self _lockedTemplate]);
    [TemplateLock unlock];
    NS_HANDLER
    DESTROY(_template);
    [TemplateLock unlock];
    [localException raise];
    NS_ENDHANDLER
    
  }
  return _template;
}

- (void) encodeWithCoder: (NSCoder*)aCoder
{
  [self notImplemented: _cmd];
  return;
}

- (id) initWithCoder: (NSCoder*)aDecoder
{
  [self notImplemented: _cmd];
  return self;
}

- (id) copyWithZone: (NSZone*)z
{

  [self notImplemented: _cmd];
  return self;
}

@end

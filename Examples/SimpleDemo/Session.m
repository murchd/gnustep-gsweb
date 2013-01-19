// Session.m from SimpleDemo
#import "Session.h"

@implementation Session

- (id) init
{
    [super init];
    [self setStoresIDsInCookies: YES];
    [self setStoresIDsInURLs: NO];
    return self;
}

@end

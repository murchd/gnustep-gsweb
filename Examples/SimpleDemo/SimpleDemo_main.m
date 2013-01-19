// SimpleDemo_main.m

#import <WebObjects/WebObjects.h>

int main (int argc, const char *argv[])
{
    int rc;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    rc = WOApplicationMain(@"SimpleDemo", argc, argv);
    [pool release];
    return rc;
}

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <WebKit/WebView.h>

@interface MyTubeAppController : NSWindowController
{
    IBOutlet NSPopUpButton *feed_type;
    IBOutlet NSTextField *search_box;
    IBOutlet IKImageBrowserView *browser;
    IBOutlet WebView *web;
    
    NSMutableArray *imageList;
}

- (IBAction)grab:(id)sender;
@end

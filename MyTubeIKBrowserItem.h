#import <Cocoa/Cocoa.h>
#import "GData/GData.h"

@interface MyTubeIKBrowserItem : NSObject {
    NSImage *image;
    GDataEntryYouTubeVideo *video;
}
- (id)initVideo:(GDataEntryYouTubeVideo *)theVideo image:(NSImage *)theImage;
- (GDataEntryYouTubeVideo *)video;
- (NSString *)imageUID;
- (NSString *)imageRepresentationType;
- (id)imageRepresentation;
- (NSString *)imageTitle;
@end

#import "MyTubeIKBrowserItem.h"
#import <Quartz/Quartz.h>

@implementation MyTubeIKBrowserItem
- (id)initVideo:(GDataEntryYouTubeVideo *)theVideo image:(NSImage *)theImage
{
    if (self = [super init])
	{
        image = [theImage copy];
        video = [theVideo copy];
    }
    return self;
}

- (GDataEntryYouTubeVideo *)video
{
    return video;
}
    
- (NSString *)imageUID
{
    return [[[[video title] stringValue] lastPathComponent] copy];
}

- (NSString *)imageRepresentationType
{
    return IKImageBrowserNSImageRepresentationType;
}

- (id)imageRepresentation
{
    return image;
}

- (NSString*)imageTitle
{
    return [self imageUID];
}

- (void)dealloc
{
    [video release];
    [image release];
    [super dealloc];
}
    
@end

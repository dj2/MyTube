#import "MyTubeAppController.h"
#import "MyTubeIKBrowserItem.h"
#import "GData/GData.h"

@interface MyTubeAppController (Private)
- (GDataServiceGoogleYouTube *)youTubeService;
- (void)fetchEntryImageURLString:(NSString *)urlString withVideo:(GDataEntryYouTubeVideo *)video;
@end

@implementation MyTubeAppController
- (void)awakeFromNib
{
    NSArray *feedTypes = [NSArray arrayWithObjects:
            @"Most Discussed",
            @"Most Linked",
            @"Most Responded",
            @"Most Viewed",
            @"Top Favorites",
            @"Recently Featured",
            nil];

    /* set the items into the field types combo box */
    [feed_type removeAllItems];
    [feed_type addItemsWithTitles:feedTypes];
    [feed_type selectItemWithTitle:@"Most Viewed"];
    
    imageList = [[NSMutableArray alloc] initWithCapacity:20];
    [browser setDelegate:self];
    [browser setDataSource:self];
}

- (IBAction)grab:(id)sender
{
    GDataServiceGoogleYouTube *service = [self youTubeService];
    GDataServiceTicket *ticket;
    
    NSString *searchString = [search_box stringValue];
    if ((searchString != nil) && ([searchString length] > 0))
    {
        NSURL *feedURL = [GDataServiceGoogleYouTube youTubeURLForFeedID:nil];
        GDataQueryYouTube *query = [GDataQueryYouTube youTubeQueryWithFeedURL:feedURL];
        [query setVideoQuery:searchString];

		ticket = [service fetchFeedWithQuery:query
									delegate:self
						   didFinishSelector:@selector(entryListFetchTicket:finishedWithFeed:error:)];
    }
    else
    {
        NSString *feedName = [[feed_type selectedItem] title];
        feedName = [feedName lowercaseString];
        feedName = [feedName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
        NSURL *feedURL = [GDataServiceGoogleYouTube youTubeURLForFeedID:feedName];

        ticket = [service fetchFeedWithURL:feedURL
								  delegate:self
						 didFinishSelector:@selector(entryListFetchTicket:finishedWithFeed:error:)];
    }
    
    [imageList removeAllObjects];
}

/* these two functions are for handling the response from fetching a feed */
- (void)entryListFetchTicket:(GDataServiceTicket *)ticket finishedWithFeed:(GDataFeedBase *)feed error:(NSError *)error
{
	if (error == nil)
	{
		GDataFeedYouTubeVideo *vfeed = (GDataFeedYouTubeVideo *)feed;
		int i;
		
		for (i = 0; i < [[vfeed entries] count]; i++)
		{
			GDataEntryBase *entry = [[vfeed entries] objectAtIndex:i];
			if (![entry respondsToSelector:@selector(mediaGroup)]) continue;
			
			GDataEntryYouTubeVideo *video = (GDataEntryYouTubeVideo *)entry;
			
			NSArray *thumbnails = [[video mediaGroup] mediaThumbnails];
			if ([thumbnails count] == 0) continue;
			
			NSString *imageURLString = [[thumbnails objectAtIndex:0] URLString];
			[self fetchEntryImageURLString:imageURLString withVideo:video];
		}
	}
	else {
		NSLog(@"fetch error: %@", error);
	}

}

- (void)entryListFetchTicket:(GDataServiceTicket *)ticket failedWithError:(NSError *)error
{
    NSLog(@"Error %@", error);
}

/* These three functions handle the responses for fetching an image */
- (void)imageFetcher:(GDataHTTPFetcher *)fetcher finishedWithData:(NSData *)data
{
    NSImage *image = [[[NSImage alloc] initWithData:data] autorelease];
    GDataEntryYouTubeVideo *video = [fetcher userData];

    [imageList addObject:[[MyTubeIKBrowserItem alloc] initVideo:video image:image]];
    [browser reloadData];
}

- (void)imageFetcher:(GDataHTTPFetcher *)fetcher failedWithStatus:(int)status data:(NSData *)data
{
    NSString *dataStr = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    NSLog(@"image fetch error %d with data %@", status, dataStr);
}

- (void)imageFetcher:(GDataHTTPFetcher *)fetcher failedWithError:(NSError *)error
{
    NSLog(@"Image fetch error %@", error);
}

/* these two functions are for the image browser delegate */
- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView *)imageBrowser
{	
	return [imageList count];
}

- (id)imageBrowser:(IKImageBrowserView *)imageBrowser itemAtIndex:(NSUInteger)index
{
	return [imageList objectAtIndex:index];
}

-(void)imageBrowser:(IKImageBrowserView *)imageBrowser cellWasDoubleClickedAtIndex:(NSUInteger)index
{
    MyTubeIKBrowserItem *item = [imageList objectAtIndex:index];
    GDataEntryYouTubeVideo *video = [item video];
    
    NSString *url = [[[[video mediaGroup] mediaContents] objectAtIndex:0] URLString];    
    [web setMainFrameURL:url];
}
@end

@implementation MyTubeAppController (Private)
- (GDataServiceGoogleYouTube *)youTubeService
{
    static GDataServiceGoogleYouTube *service = nil;
    
    if (!service)
	{
        service = [[GDataServiceGoogleYouTube alloc] init];
        [service setUserAgent:@"MyTube-1.0"];
        [service setShouldCacheDatedData:YES];
        
        /* this is where we'd set the username/password if we accepted one */
        [service setUserCredentialsWithUsername:nil password:nil];
    }
    
    return service;
}

/* fetch a specific image URL from YouTube */
- (void)fetchEntryImageURLString:(NSString *)urlString withVideo:(GDataEntryYouTubeVideo *)video
{
    if (!urlString) return;
    
    NSURL *imageURL = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
    GDataHTTPFetcher *fetcher = [GDataHTTPFetcher httpFetcherWithRequest:request];
    [fetcher setUserData:video];
    
    [fetcher beginFetchWithDelegate:self
                  didFinishSelector:@selector(imageFetcher:finishedWithData:)
          didFailWithStatusSelector:@selector(imageFetcher:failedWithStatus:data:)
           didFailWithErrorSelector:@selector(imageFetcher:failedWithError:)];
}
@end


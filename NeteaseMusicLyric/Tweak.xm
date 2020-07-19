#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>

@interface NMPlayerManager
@property(nonatomic) long long highlightedLyricIndex; 
@property(retain, nonatomic) NSArray *lyricsArray; 
@end


@interface NMLyricObject
@property(retain, nonatomic) NSString *translatedLyric; 
@property(retain, nonatomic) NSString *lyric;
@end


%hook NMPlayerManager
-(void)setHighlightedLyricIndex:(long long)arg1 {
	NMLyricObject *lrcObject = [self.lyricsArray objectAtIndex: arg1];
    NSString *lrc_origin = lrcObject.lyric;
	NSString *lrc_translate = lrcObject.translatedLyric;
    NSLog(@"mlyx_xxxx Index %lld  lrc %@  lrc_trans %@",arg1,lrc_origin,lrc_translate);

	NSMutableDictionary *info=[NSMutableDictionary dictionary];
	[info setObject:lrc_origin forKey:@"lrc_origin"];
    [info setObject:lrc_translate forKey:@"lrc_translate"];

	CPDistributedMessagingCenter *c=[CPDistributedMessagingCenter centerNamed:@"mlyx.neteasemusiclyric"];
	rocketbootstrap_distributedmessagingcenter_apply(c);
	[c sendMessageName:@"LyricChange" userInfo:info];
}
%end
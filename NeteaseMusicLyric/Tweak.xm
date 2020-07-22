#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>


@interface NMLyricModel
@property(retain, nonatomic) NSMutableArray *lyricList;
@property(nonatomic) _Bool hasRomaji; 
@property(nonatomic) _Bool hasTranslation;
@end

@interface NMPlayerManager
@property(nonatomic) long long highlightedLyricIndex; 
@property(retain, nonatomic) NMLyricModel *lyricModel;
@end


@interface NMLyricObject
@property(retain, nonatomic) NSString *lyric;
@property(retain, nonatomic) NSString *translatedLyric; 
@property(retain, nonatomic) NSString *romajiLyric;
@end


%hook NMPlayerManager

-(void)setHighlightedLyricIndex:(long long)arg1 {
	NMLyricModel *lyricModel = self.lyricModel ;

	NMLyricObject *lrcObject = [lyricModel.lyricList objectAtIndex: arg1];

    NSString *lrc_origin = lrcObject.lyric;
	NSString *lrc_translate = lrcObject.translatedLyric;
	NSString *lrc_romaji = lrcObject.romajiLyric;
    NSLog(@"mlyx_xxxx Index %lld  lrc %@  lrc_trans %@ lrc_romaji %@",arg1,lrc_origin,lrc_translate,lrc_romaji);

	NSMutableDictionary *info=[NSMutableDictionary dictionary];
	[info setObject:lrc_origin forKey:@"lrc_origin"];
    [info setObject:lrc_translate forKey:@"lrc_translate"];
	[info setObject:lrc_romaji forKey:@"lrc_romaji"];

	CPDistributedMessagingCenter *c=[CPDistributedMessagingCenter centerNamed:@"mlyx.neteasemusiclyric"];
	rocketbootstrap_distributedmessagingcenter_apply(c);
	[c sendMessageName:@"LyricChange" userInfo:info];
}
%end
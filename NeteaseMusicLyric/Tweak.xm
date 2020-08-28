#import <MRYIPCCenter.h>

MRYIPCCenter* center = [MRYIPCCenter centerNamed:@"mlyx.neteasemusiclyric"];

static NSString* lastLyric;
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

	if([lastLyric isEqualToString:lrc_origin])
		return;
	
	lastLyric=lrc_origin;
	
	NSString *lrc_translate = lrcObject.translatedLyric;
	NSString *lrc_romaji = lrcObject.romajiLyric;
    NSLog(@"mlyx_netease Index %lld  lrc %@  lrc_trans %@ lrc_romaji %@",arg1,lrc_origin,lrc_translate,lrc_romaji);

	NSDictionary *info = @{@"lrc_origin" : lrc_origin, @"lrc_translate" : lrc_translate, @"lrc_romaji" : lrc_romaji};

	[center callExternalMethod:@selector(_updateLyric:) withArguments:info];

}
%end
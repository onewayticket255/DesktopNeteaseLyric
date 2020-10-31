//Recommend Spotify Area: India

#import <MRYIPCCenter.h>

MRYIPCCenter* center = [MRYIPCCenter centerNamed:@"mlyx.neteasemusiclyric"];

@interface SPTLyricsLine
@property(readonly, copy, nonatomic) NSString *text;
@end


@interface SPTLyricsLineSet
@property(readonly, copy, nonatomic) NSArray *lyricLines; 
@end

@interface SPTLyricsV2LyricsSyllableProgressManager
@property(nonatomic) long long activeLineIndex;
@property(retain, nonatomic) SPTLyricsLineSet *lyricsLineSet;
@end

%hook SPTLyricsV2LyricsSyllableProgressManager

-(void)setActiveLineIndex:(long long)arg1 {
    %orig;

    if(arg1>=0){
		NSLog(@"mlyxshi SpotifyLyricsIndex %lld",arg1);
		SPTLyricsLineSet *lyricsLineSet = self.lyricsLineSet;
		NSArray *lyricLines =lyricsLineSet.lyricLines;
		SPTLyricsLine *lyric =lyricLines[arg1];
		NSLog(@"mlyxshi SpotifyLyrics %@",lyric.text);

		NSDictionary *info = @{@"lrc_origin" : lyric.text, @"lrc_translate" : @"", @"lrc_romaji" : @""};
		[center callExternalMethod:@selector(_updateLyric:) withArguments:info];
	}else{
		NSDictionary *info = @{@"lrc_origin" : @"", @"lrc_translate" : @"", @"lrc_romaji" : @""};
		[center callExternalMethod:@selector(_updateLyric:) withArguments:info];

	} 

}

-(void)applicationDidEnterBackground {

}

%end

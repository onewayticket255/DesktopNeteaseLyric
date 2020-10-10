//Recommend Spotify Area: India

#import <MRYIPCCenter.h>

MRYIPCCenter* center = [MRYIPCCenter centerNamed:@"mlyx.neteasemusiclyric"];

@interface SPTLyricsLine
@property(readonly, copy, nonatomic) NSString *text;
@end


@interface SPTLyricsLineSet
@property(readonly, copy, nonatomic) NSArray *lyricLines; 
@end

@interface SPTLyricsV2LyricsViewController
@property(nonatomic) long long lineIndex; 
@property(retain, nonatomic) SPTLyricsLineSet *lyricsLineSet;
@end


/*
This hook method requires Spotify always in Foreground
Details: /SpringBoardExtra/SpotifyForeground.xm
*/
%hook SPTLyricsV2LyricsViewController

-(void)setLineIndex:(long long)arg1 {
    %orig;
	if(arg1>=0){
		NSLog(@"mlyx SpotifyLyricsIndex %lld",arg1);
		SPTLyricsLineSet *lyricsLineSet = self.lyricsLineSet;
		NSArray *lyricLines =lyricsLineSet.lyricLines;
		SPTLyricsLine *lyric =lyricLines[arg1];
		NSLog(@"mlyx SpotifyLyrics %@",lyric.text);

	    NSDictionary *info = @{@"lrc_origin" : lyric.text, @"lrc_translate" : @"", @"lrc_romaji" : @""};
	    [center callExternalMethod:@selector(_updateLyric:) withArguments:info];
	}    
}

%end

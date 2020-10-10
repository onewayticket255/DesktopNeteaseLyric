//Keep Spotify in Foreground, Otherwise, [SPTLyricsV2LyricsViewController -(void)setLineIndex:(long long)arg1] will not run.

@interface FBSMutableSceneSettings: NSObject
@end
@interface UIMutableApplicationSceneSettings : FBSMutableSceneSettings
-(void)setForeground:(BOOL)arg1 ;
@end

@interface FBProcess : NSObject
@property (nonatomic,copy,readonly) NSString * bundleIdentifier;     
@end

@interface FBScene : NSObject
@property (nonatomic,readonly) FBProcess * clientProcess;
-(void)updateSettings:(UIMutableApplicationSceneSettings *)arg1 withTransitionContext:(id*)arg2;
-(void)updateSettings:(UIMutableApplicationSceneSettings *)arg1 withTransitionContext:(id)arg2 completion:(/*^block*/id)arg3 ;
@end

%hook FBScene
-(void)updateSettings:(UIMutableApplicationSceneSettings *)arg1 withTransitionContext:(id)arg2 completion:(/*^block*/id)arg3{  
	
	if([self.clientProcess.bundleIdentifier isEqualToString:@"com.spotify.client"]&& [arg1 respondsToSelector:@selector(setForeground:)]){
        [arg1 setForeground:1];
	}

	%orig;
	
}
%end
@interface QMRootTabBarItem:UIView
@property(copy, nonatomic) NSString *title;
@end

@interface QMRecommendWordLabel:UILabel
@end

@interface QMRelatedVideoView:UIView
@end

@interface QMbrandAdPendantView:UIView
@end



//TAB
%hook QMRootTabBarItem
- (void)layoutSubviews{
  %orig;

  if([self.title isEqualToString:@"首页"]||[self.title isEqualToString:@"我的"])
    return;

  [self removeFromSuperview];  
}
%end

//splash
%hook FlashScreenManager
-(id)init{
  return nil;
}
%end

//search placeholder
%hook QMRecommendWordLabel 
- (void)layoutSubviews{
 [self removeFromSuperview];
}
%end

//hot search
%hook OnLineSearchViewController
-(void)setHotWordView:(id)arg1{
}
%end

//抽绿钻
%hook QMbrandAdPendantView
- (void)layoutSubviews{
  [self removeFromSuperview];
}
%end

//我的 广告
%hook QMMyMusicAdBannerCell
+ (double)cellHeight{
  return 0;
}
%end


//歌单 底部
%hook QMPROmgAdBannerView
- (id)initWithFrame:(struct CGRect)arg1{
  return nil;
}
%end


//播放界面 相关视频
%hook QMRelatedVideoView
- (void)layoutSubviews{
  %orig;
  [self removeFromSuperview];
}
%end

//播放界面 正在唱
%hook QMPlayerSnackBarAdManager
-(bool)canRequestAd{
  return 0;
}

%end

%ctor{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/mlyx.neteaselyricsetting.plist"];
    bool isCleanQQMusicEnabled=[settings objectForKey:@"isCleanQQMusicEnabled"] ? [[settings objectForKey:@"isCleanQQMusicEnabled"] boolValue] : 1;
    if(isCleanQQMusicEnabled){
        %init;
    }
}
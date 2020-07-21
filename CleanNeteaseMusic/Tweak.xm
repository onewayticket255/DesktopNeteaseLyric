@interface NMTabBar:UIView
@end

@interface ATScrollView:UIScrollView
@end


//屏蔽无用网络请求
%hook NMUploadLogRequest
//  feedback/client/log
-(id)initWithFile:(void *)arg2 {
    return nil;
}
-(id)initWithZipFile:(void *)arg2 {
	return nil;
}
%end

%hook NMRealTimeLogRequest 
//  feedback/weblog
-(id)initWithAction:(id)arg2 log:(id)arg3 {
    return nil;
}
%end

%hook NMPollingRequest 
//  pl/count
-(id)init {
    return nil;
}
%end

%hook NMUserSafePollingRequest 
//  usersafe/pl/count
-(id)init {
    return nil;
}
%end

%hook  NMStartupAdvertisementShowRequest 
// ad/monitor/impress
-(id)initWithAdvertisement:(id)arg2 {
	return nil;
}
%end

%hook NMAdvertisementFetchRequest 
// ad/get
-(id)initWithTypeIdPairList:(id)arg2 otherParams:(id)arg3 {
	return nil;
}
%end


%hook NMRefreshStartupIntervalRequest 
//  ad/config
-(id)init {
	return nil;
}
%end


%hook NMStartupAdvertisementPreFetchRequest 
// ad/loading/get
-(id)init {
	return nil;
}
%end



%hook NMAdvertisementFetchConfigRequest
// ad/commonconfig
-(id)init {
	return nil;
}
%end


%hook NMPlayerViewADConfRequest
// ad/config/get
-(id)init {
	return nil;
}
%end


%hook MAMDNSServerFinder 
// nstool.netease.com
+(void)startNSInfoCompleteHandler:(id)arg2 {
}
%end


%hook NMSearchPopularRequest 
// hot/search
-(id)init {
	return nil;
}
%end

%hook NMMAMFileUploadRequest
//  log/mam/upload
-(id)initWithAttachedFile:(void *)arg2 {
    return nil;
}
%end



//底栏
%hook NMTabBar
- (void)layoutSubviews{
   %orig;
	for(UIView *subview in [self subviews]){
      	if([subview isKindOfClass: %c(UILabel)]){
         	UILabel *label=(UILabel *)subview;
         	if([label.text isEqualToString:@"视频"]||[label.text isEqualToString:@"云村"]){
			   [subview removeFromSuperview];    
         	}
        }

        if([subview class]== %c(NMTabBadgeView)){
     		 [subview removeFromSuperview];       
        }

      	if([subview isKindOfClass: %c(UIImageView)]){
         	UIImageView *imageview=(UIImageView *)subview;
         	UIImage *image=imageview.image;
         	UIImageAsset* imageAsset=MSHookIvar<UIImageAsset*> (image, "_imageAsset");
         
         	if(imageAsset){       
            	NSString* assetName=MSHookIvar<NSString*> (imageAsset, "_assetName");
            	if([assetName isEqualToString:@"cm6_btm_icn_video"]||[assetName isEqualToString:@"cm6_btm_icn_friend"]){
					[subview removeFromSuperview];    
            	}          
         	}
        }
    
	}
}
%end


//搜索ad
%hook NMSearchViewController
- (void)loadAds{

}
%end



//搜索placeholder
%hook NMNavigationSearchBarView
- (void)setPlaceHolder:(id)arg1  enablesReturnKey:(BOOL)arg2 {
}
%end

//Splash Ad
%hook NMLaunchAdViewController
- (id)init{
	return nil;
}
%end

//播放界面防误触
%hook ATScrollView
- (void)layoutSubviews{
    %orig;
	self.userInteractionEnabled=0;
}
%end

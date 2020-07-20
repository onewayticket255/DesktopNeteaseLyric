@interface NMSettingBallView:UIView
@end

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

%hook NMUserSafePollingRequest 
//  usersafe/pl/count
-(id)init {
    return nil;
}
%end


%hook NMPollingRequest 
//  pl/count
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


%hook NMStartupAdvertisementPreFetchRequest
-(id)init{
// ad/loading
	return nil;
}
%end


%hook NMAdvertisementFetchRequest
-(id)initWithTypeIdPairList:(void *)arg2 {
// ad/get
	return nil;
}
%end


//hide 无用信息
%hook NMSettingBallView
- (void)layoutSubviews{
   %orig;
	for(UIView *subview in [self subviews]){
      if([subview isKindOfClass: %c(UILabel)]){
        	UILabel *label=(UILabel *)subview;
         	if([label.text isEqualToString:@"商城"]||[label.text isEqualToString:@"有票"]||[label.text isEqualToString:@"个性换肤"]){
            	self.hidden=1;
         	}
        }
    }
}
%end

%hook NMTabBar
- (void)layoutSubviews{
   %orig;
	for(UIView *subview in [self subviews]){
      	if([subview isKindOfClass: %c(UILabel)]){
         	UILabel *label=(UILabel *)subview;
         	if([label.text isEqualToString:@"视频"]||[label.text isEqualToString:@"朋友"]){
            	label.hidden=1;
         	}
        }

        if([subview class]== %c(NMTabBadgeView)){
         	subview.hidden=1;         
        }

      	if([subview isKindOfClass: %c(UIImageView)]){
         	UIImageView *imageview=(UIImageView *)subview;
         	UIImage *image=imageview.image;
         	UIImageAsset* imageAsset=MSHookIvar<UIImageAsset*> (image, "_imageAsset");
         
         	if(imageAsset){       
            	NSString* assetName=MSHookIvar<NSString*> (imageAsset, "_assetName");
            	if([assetName isEqualToString:@"cm6_btm_icn_video"]||[assetName isEqualToString:@"cm6_btm_icn_friend"]){
               		imageview.hidden=1;
            	}          
         	}
        }
    
	}
}
%end

%hook NMDiscoverRecommendViewController
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   return indexPath.section==0&&indexPath.row==0?%orig:0;
}

- (void)loadBanner{
}

- (void)doLoadBanner{
}
%end

%hook NMSearchViewController
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
   return indexPath.section==2?%orig:0;
}
%end

%hook NMNavigationSearchBarView
- (void)setPlaceHolder:(id)arg1  enablesReturnKey:(BOOL)arg2 {
}
%end

%hook NMAdBackgroundView
- (id)initWithFrame:(struct CGRect)arg1{
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
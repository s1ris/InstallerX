@protocol VeloxFolderViewProtocol
+(int)folderHeight;
-(UIView *)initWithFrame:(CGRect)aFrame;
@optional
-(void)unregisterFromStuff;
-(float)realHeight;
@end

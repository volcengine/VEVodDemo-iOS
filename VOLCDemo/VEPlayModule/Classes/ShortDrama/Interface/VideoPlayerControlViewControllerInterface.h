//
//  MXMyProgramViewController.h
//  VOLCDemo
//

@protocol VideoPlayerControlViewControllerInterface <NSObject>

- (void)reloadData:(id)dataObj;

- (void)cleanScreen:(BOOL)isClean animate:(BOOL)animate;

- (void)closePlayer;

@end

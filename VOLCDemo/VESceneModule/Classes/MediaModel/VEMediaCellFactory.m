//
//  VEMediaCellFactory.m
//  VESceneModule
//
//  Created by litao.he on 2024/11/15.
//

#import "VEMediaCellFactory.h"
#import "VEDramaVideoInfoModel.h"
#import "VEAdInfoModel.h"
#import "VEAdOperator.h"
#import "VEAdCellController.h"
#import "VEShortDramaDetailVideoCellController.h"
#import "VEShortDramaVideoCellController.h"

static NSString *VEAdsCellReuseID = @"VEAdsCellReuseID";
static NSString *VEShortDramaDetailVideoFeedCellReuseID = @"VEShortDramaDetailVideoFeedCellReuseID";
static NSString *VEShortDramaVideoFeedCellReuseID = @"VEShortDramaVideoFeedCellReuseID";

@implementation VEMediaCellFactory

+ (UIViewController<VEPageItem> *)createCellViewControllerByMediaModel:(id)mediaModel pageViewController:(VEPageViewController*)pageViewController cellDelegate:(id)cellDelegate adDelegate:(id)adDelegate adRespDelegate:(id)adRespDelegate andSceneType:(NSInteger)sceneType {
    if ([mediaModel isKindOfClass:[VEAdInfoModel class]]) {
        VEAdInfoModel* adInfoModel = mediaModel;
        VEAdCellController *cell = [pageViewController dequeueItemForReuseIdentifier:VEAdsCellReuseID];
        if (!cell) {
            cell = [VEAdCellController new];
            cell.reuseIdentifier = VEAdsCellReuseID;
        }
        cell.adDelegate = adDelegate;
        cell.responderDelegate = adRespDelegate;
        cell.hostSceneType = sceneType;
        [cell loadAd:adInfoModel];
        return cell;
    } else if ([mediaModel isKindOfClass:[VEDramaVideoInfoModel class]]) {
        // 1 for detail, 2 for recommond
        if (sceneType == 1) {
            VEShortDramaDetailVideoCellController* cell = [pageViewController dequeueItemForReuseIdentifier:VEShortDramaDetailVideoFeedCellReuseID];
            if (!cell) {
                cell = [VEShortDramaDetailVideoCellController new];
                cell.reuseIdentifier = VEShortDramaDetailVideoFeedCellReuseID;
            }
            cell.delegate = cellDelegate;
            [cell reloadData:mediaModel];
            return cell;
        } else if (sceneType == 2) {
            VEShortDramaVideoCellController *cell = [pageViewController dequeueItemForReuseIdentifier:VEShortDramaVideoFeedCellReuseID];
            if (!cell) {
                cell = [VEShortDramaVideoCellController new];
                cell.delegate = cellDelegate;
                cell.reuseIdentifier = VEShortDramaVideoFeedCellReuseID;
            }
            [cell reloadData:mediaModel];
            return cell;
        }
    }
    return nil;
}

@end

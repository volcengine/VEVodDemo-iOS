//
//  VEDramaInfoModel.m
//  VEPlayModule
//

#import "VEDramaInfoModel.h"

@implementation VEDramaInfoModel

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"dramaId": @"dramaId",
        @"dramaTitle": @"dramaTitle",
        @"dramaDes": @"description",
        @"coverUrl": @"coverUrl",
        @"authorId": @"authorId",
        @"latestEpisodeNumber": @"latestEpisodeNumber",
        @"totalEpisodeNumber": @"totalEpisodeNumber",
    }];
}

+ (BOOL)propertyIsOptional:(NSString*)propertyName {
    return YES;
}

@end

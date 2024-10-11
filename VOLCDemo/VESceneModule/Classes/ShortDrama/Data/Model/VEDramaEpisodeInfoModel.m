//
//  VEDramaEpisodeInfoModel.m
//  VEPlayModule
//

#import "VEDramaEpisodeInfoModel.h"

@implementation VEDramaEpisodeInfoModel

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithModelToJSONDictionary:@{
        @"episodeNumber": @"episodeNumber",
        @"episodeDesc": @"episodeDesc",
        @"dramaInfo": @"dramaInfo"
    }];
}

+ (Class)classForCollectionProperty:(NSString *)propertyName {
    if ([propertyName isEqualToString:@"dramaInfo"]) {
        return VEDramaInfoModel.class;
    }
    return nil;
}

+ (BOOL)propertyIsOptional:(NSString*)propertyName {
    return YES;
}

@end

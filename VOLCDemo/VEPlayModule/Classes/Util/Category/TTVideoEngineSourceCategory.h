//
//  TTVideoEngineSourceCategory.h
//  VOLCDemo
//
//  Created by real on 2022/8/22.
//  Copyright © 2022 ByteDance. All rights reserved.
//

@import Foundation;
#import <TTSDK/TTVideoEngineVidSource.h>
#import <TTSDK/TTVideoEngineUrlSource.h>
#import <TTSDK/TTVideoEngineMultiEncodingUrlSource.h>


@interface TTVideoEngineMultiEncodingUrlSource (VECodecUrlSource)

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *cover;

@end

@interface TTVideoEngineVidSource (VEVidSource)

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *cover;

@end

@interface TTVideoEngineUrlSource (VEUrlSource)

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *cover;

@end


// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  VEAPISwiftVideoModel.swift
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/5/27.
//

import Foundation
import TTSDKFramework

class VEAPISwiftVideoModel: NSObject {
    @objc static func removeAllCachesSwift(_ flag: Bool) {
        // true 清除所有缓存；false LRU 保留最近 10 条缓存。
        TTVideoEngine.ls_clearAllCaches(flag);
    }
    
    static func initDirectUrlSource(_ directUrl: String) -> TTVideoEngineUrlSource {
        let cacheKey = VEAPITools.md5(with: directUrl);
        return TTVideoEngineUrlSource(url: directUrl, cacheKey: cacheKey);
    }
    
    static func initVidSource(vid: String, playAuthToken: String, resolution: TTVideoEngineResolutionType) -> TTVideoEngineVidSource {
        return TTVideoEngineVidSource(vid: vid, playAuthToken: playAuthToken, resolution: resolution);
    }
    
    static func defaultVideoModel() -> [VEAPIVideoModel] {
        return VEAPIVideoModel.defaultVideoModel();
    }
    
    static func defaultSubtitleSubIDs() -> [[String: NSNumber]] {
        return VEAPIVideoModel.defaultSubtitleSubIDs();
    }
    
    static func convertVideoModelToTTVideoEngineSource(_ videoModel: VEAPIVideoModel) -> TTVideoEngineMediaSource? {
        var source: TTVideoEngineMediaSource?;
        let videoUrl = videoModel.videoUrl;
        let cacheKey = VEAPITools.md5(with: videoUrl);
        source = TTVideoEngineUrlSource(url: videoUrl, cacheKey: cacheKey);
        return source;
    }
    
    static func covertVideoModelsToTTVideoEngineSources(_ videoModels: [VEAPIVideoModel]) -> [TTVideoEngineMediaSource] {
        var ret: [TTVideoEngineMediaSource] = [];
        for obj in videoModels {
            if let tempObj = Self.convertVideoModelToTTVideoEngineSource(obj) {
                ret.append(tempObj);
            }
        }
        return ret;
    }
}

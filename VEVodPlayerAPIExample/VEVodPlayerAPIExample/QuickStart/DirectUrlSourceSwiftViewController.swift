// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  DirectUrlSourceSwiftExample.swift
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/5/27.
//

import UIKit
import TTSDKFramework
import SnapKit

@objc(DirectUrlSourceSwiftViewController)
class DirectUrlSourceSwiftViewController: UIViewController {
    
    private var engine: TTVideoEngine?;
    private var needToResume: Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        NSLog("VEVodPlayerAPIExample - DirectUrlSourceSwiftViewController");
        setupUI();
        setupVideoEngine();
        // 注册通知监听，进入后台以及从后台恢复时，手动管理一下播放器状态
        NotificationCenter.default.addObserver(self, selector: #selector(handleResignActive(_:)), name: UIApplication.willResignActiveNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(handleBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil);
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        // 移除播放器视图
        engine?.playerView.removeFromSuperview();
        
        // 异步关闭播放器
        engine?.closeAysnc();
        engine = nil;
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    private func setupUI() {
        view.backgroundColor = .white;
    }
    
    private func setupVideoEngine() {
        // 初始化播放器
        engine = TTVideoEngine(ownPlayer: true);
        
        guard let playerView = engine?.playerView else {
            NSLog("Player view initialization failed");
            return;
        }
        
        // 添加播放器视图
        view.addSubview(playerView);
        playerView.snp.makeConstraints { make in
            make.edges.equalToSuperview();
        }
        
        // 开启优化前后台切换卡顿开关
        engine?.setOptionForKey(VEKKey.VEKKeyIsDecodeMalFunctionErrorIgnore.rawValue, value: NSNumber(value: 1));
        // 开启优化前后台切换跳帧开关
        engine?.setOptionForKey(VEKKey.VEKKeyPlayerIsIgnoreTestSizeOnPause.rawValue, value: NSNumber(value: 1));
        
        // 配置播放源
        let videoModel = VEAPISwiftVideoModel.defaultVideoModel()[0];
        let videoUrl = videoModel.videoUrl;
        
        let urlSource = VEAPISwiftVideoModel.initDirectUrlSource(videoUrl);
        engine?.setVideoEngineVideoSource(urlSource);
        engine?.play();
    }
    
    @objc func handleResignActive(_ notification: Notification) {
        NSLog("VEVodPlayerAPIExample - applicationWillResignActive from DirectUrlSourceSwiftViewController");
        // 即将进入后台时，若视频正在播放，则需要暂停
        if (self.engine?.playbackState == .playing) {
            self.engine?.pause();
            self.needToResume = true;
        } else {
            self.needToResume = false;
        }
    }
    
    @objc func handleBecomeActive(_ notification: Notification) {
        NSLog("VEVodPlayerAPIExample - applicationDidBecomeActive in DirectUrlSourceSwiftViewController");
        // 从后台回复后，若视频之前是播放状态，则需要恢复播放
        if (self.needToResume) {
            self.engine?.play();
        }
    }
}

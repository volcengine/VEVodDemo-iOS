// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  BasicPlayerbackSwiftViewController.swift
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/5/28.
//

import Foundation
import TTSDKFramework
import SnapKit

@objc(BasicPlayerbackSwiftViewController)
@MainActor class BasicPlayerbackSwiftViewController: UIViewController {
    private var engine: TTVideoEngine?;
    private var buttonNum = 0;
    private lazy var progressSliderForPlay: UISlider = {
        let view = UISlider();
        view.minimumTrackTintColor = .blue;
        view.addTarget(self, action: #selector(sliderValueChanged(_:)), for: [.touchUpInside, .touchUpOutside]);
        view.tag = 0;
        return view;
    }()
    private lazy var progressSliderForCache: UISlider = {
        let view = UISlider();
        view.minimumTrackTintColor = .blue;
        view.tag = 1;
        return view;
    }()
    private lazy var progressSliderForSound: UISlider = {
        let view = UISlider();
        view.minimumTrackTintColor = .blue;
        view.addTarget(self, action: #selector(sliderValueChanged(_:)), for: [.touchUpInside, .touchUpOutside]);
        view.maximumValue = 1.0;
        view.tag = 2;
        return view;
    }()
    private lazy var playLabel: UILabel = {
        let view = UILabel();
        view.text = NSLocalizedString("play_progress_label", comment: "");
        return view;
    }()
    private lazy var cacheLabel: UILabel = {
        let view = UILabel();
        view.text = NSLocalizedString("cache_progress_label", comment: "");
        return view;
    }()
    var progressTimer: Timer?;
    var playStartTime: Float = 0.0;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        NSLog("VEVodPlayerAPIExample - BasicPlayerbackSwiftViewController");
        setupUI();
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        engine?.playerView.removeFromSuperview();
        engine?.closeAysnc();
        engine = nil;
    }
    
    private func setupUI() {
        view.backgroundColor = .white;
        setupPlayer();
        
        guard let engine = self.engine else {
            NSLog("VEVodPlayerAPIExample - engine is nil");
            return
        }
        view.addSubview(playLabel)
        playLabel.snp.makeConstraints { make in
            make.top.equalTo(engine.playerView.snp.bottom).offset(3)
            make.left.equalToSuperview().offset(5)
            make.width.equalTo(300)
            make.height.equalTo(30)
        }
        view.addSubview(progressSliderForPlay);
        progressSliderForPlay.snp.makeConstraints { make in
            make.top.equalTo(playLabel.snp.bottom).offset(3);
            make.left.right.equalToSuperview().inset(10);
        }

        view.addSubview(cacheLabel)
        cacheLabel.snp.makeConstraints { make in
            make.top.equalTo(progressSliderForPlay.snp.bottom);
            make.left.equalToSuperview().offset(5)
            make.width.equalTo(300)
            make.height.equalTo(30)
        }
        view.addSubview(progressSliderForCache);
        progressSliderForCache.snp.makeConstraints { make in
            make.top.equalTo(cacheLabel.snp.bottom).offset(3);
            make.left.right.equalToSuperview().inset(10);
        }
        
        let controlLabel = UILabel();
        controlLabel.text = NSLocalizedString("control_label", comment: "");
        view.addSubview(controlLabel)
        controlLabel.snp.makeConstraints { make in
            make.top.equalTo(progressSliderForCache.snp.bottom).offset(3)
            make.left.equalToSuperview().offset(5)
            make.width.equalTo(300)
            make.height.equalTo(30)
        }
        let controlTitles = [NSLocalizedString("control_play", comment: ""), NSLocalizedString("control_pause", comment: ""), NSLocalizedString("control_set_time", comment: "")];
        createButtons(titles: controlTitles, width: 75, under: controlLabel);
        
        let speedLabel = UILabel();
        speedLabel.text = NSLocalizedString("speed_label", comment: "");
        view.addSubview(speedLabel);
        speedLabel.snp.makeConstraints { make in
            make.top.equalTo(controlLabel.snp.bottom).offset(41);
            make.left.equalToSuperview().offset(5);
            make.width.equalTo(300);
            make.height.equalTo(30);
        }
        let speedTitles = ["0.5", "1.0", "1.5", "2.0"];
        createButtons(titles: speedTitles, width: 75, under: speedLabel);
        
        let loopLabel = UILabel();
        loopLabel.text = NSLocalizedString("loop_label", comment: "");
        view.addSubview(loopLabel);
        loopLabel.snp.makeConstraints { make in
            make.top.equalTo(speedLabel.snp.bottom).offset(41);
            make.left.equalToSuperview().offset(5);
            make.width.equalTo(300);
            make.height.equalTo(30);
        }
        let loopTitles = ["false", "true"];
        createButtons(titles: loopTitles, width: 75, under: loopLabel);
        
        let muteLabel = UILabel();
        muteLabel.text = NSLocalizedString("mute_label", comment: "");
        view.addSubview(muteLabel);
        muteLabel.snp.makeConstraints { make in
            make.top.equalTo(loopLabel.snp.bottom).offset(41);
            make.left.equalToSuperview().offset(5);
            make.width.equalTo(300);
            make.height.equalTo(30);
        }
        let muteTitles = ["false", "true"];
        createButtons(titles: muteTitles, width: 75, under: muteLabel);
        
        let soundLabel = UILabel();
        soundLabel.text = NSLocalizedString("sound_label", comment: "");
        view.addSubview(soundLabel);
        soundLabel.snp.makeConstraints { make in
            make.top.equalTo(muteLabel.snp.bottom).offset(41);
            make.left.equalToSuperview().offset(5);
            make.width.equalTo(300);
            make.height.equalTo(30);
        }
        view.addSubview(progressSliderForSound);
        progressSliderForSound.snp.makeConstraints { make in
            make.top.equalTo(soundLabel.snp.bottom).offset(3);
            make.left.right.equalToSuperview().inset(10);
        }
    }
    
    private func createButtons(titles: [String], width: CGFloat, under label: UIView) {
        for (index, title) in titles.enumerated() {
            let button = VEAPIButton(title: title)
            button.tag = buttonNum
            buttonNum += 1
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            view.addSubview(button)
            
            button.snp.makeConstraints { make in
                make.top.equalTo(label.snp.bottom).offset(3)
                make.left.equalToSuperview().offset((width + 5) * CGFloat(index) + 3)
                make.width.equalTo(width)
                make.height.equalTo(35)
            }
        }
    }
    
    private func inputPlayStartTime() {
        // 设置指定起播时间
        let alertController = UIAlertController(title: NSLocalizedString("control_set_time", comment: ""),
                                              message: nil,
                                       preferredStyle: .alert)
        
        // 添加确定按钮
        let confirmAction = UIAlertAction(title: NSLocalizedString("ok_label", comment: ""), style: .default) { [weak self] _ in
            guard let textField = alertController.textFields?.first,
                    let inputText = textField.text else {
                return
            }
            
            // 转换为浮点数（如果无效则默认为0）
            self?.playStartTime = Float(inputText) ?? 0
            NSLog("VEVodPlayerAPIExample - playStartTime: \(inputText)")
        }
        alertController.addAction(confirmAction)
        
        // 添加文本输入框
        alertController.addTextField { [weak self] textField in
            // 显示当前起播时间值
            textField.text = String(self?.playStartTime ?? 0)
                
            // 配置键盘类型（可选）
            textField.keyboardType = .decimalPad
        }
        
        // 安全获取并呈现视图控制器
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        
        rootViewController.present(alertController, animated: true)
    }
    
    private func setupPlayer() {
        let topOffset = UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.height ?? 0);
        // 初始化播放器
        engine = TTVideoEngine(ownPlayer: true);
        engine?.delegate = self;
        
        guard let playerView = engine?.playerView else {
            NSLog("Player view initialization failed");
            return;
        }
        
        // 添加播放器视图
        view.addSubview(playerView);
        playerView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(topOffset);
            make.left.width.equalToSuperview();
            make.height.equalToSuperview().multipliedBy(0.3);
        }
        
        // 配置播放源
        let videoModel = VEAPISwiftVideoModel.defaultVideoModel()[0];
        let videoUrl = videoModel.videoUrl;
        
        let urlSource = VEAPISwiftVideoModel.initDirectUrlSource(videoUrl);
        engine?.setVideoEngineVideoSource(urlSource);
        
        // 设置屏幕长亮
        // 方式一，通过系统 API 设置
    //    [UIApplication sharedApplication].idleTimerDisabled = YES;
        // 方式二，通过 SDK 提供的 API 设置
        engine?.setOptionForKey(VEKKey.VEKKeyPlayerIdleTimerAuto_NSInteger.rawValue, value:true);
        
        // 如果只想调整单个视频的音量，需要在 play 之前配置 AudioDevice
        engine?.setOptionForKey(VEKKey.VEKKeyPlayerAudioDevice_ENUM.rawValue, value:TTVideoEngineAudioDeviceType.deviceAudioGraph.rawValue);
        
        progressSliderForSound.value = Float(engine?.volume ?? 1.0);
        
        progressTimer?.invalidate()
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { [weak self] _ in
            Task { @MainActor in
                // 获取播放时长
                let duration = self?.engine?.duration;
                let currentPlaybackTime = self?.engine?.currentPlaybackTime;
                let playableDuration = self?.engine?.playableDuration;
                if (duration ?? 0 > 0) {
                    self?.progressSliderForPlay.maximumValue = Float(duration ?? 0.0);
                    self?.progressSliderForCache.maximumValue = Float(duration ?? 0.0);
                    // 获取当前播放位置
                    self?.progressSliderForPlay.value = Float(currentPlaybackTime ?? 0.0);
                    // 获取缓存进度
                    self?.progressSliderForCache.value = Float(playableDuration ?? 0.0);
                }
                let currentPlaybackTimeStr = VEAPITools.convertSeconds(toStr: currentPlaybackTime ?? 0);
                let playableDurationStr = VEAPITools.convertSeconds(toStr: playableDuration ?? 0);
                let durationStr = VEAPITools.convertSeconds(toStr: duration ?? 0);
                self?.playLabel.text = "播放进度:\(currentPlaybackTimeStr ?? "00:00:00")/\(durationStr ?? "00:00:00")";
                self?.cacheLabel.text = "视频缓存进度:\(playableDurationStr ?? "00:00:00")/\(durationStr ?? "00:00:00")";
            }
        })
    }
    
    @objc private func sliderValueChanged(_ sender: UISlider) {
        if (sender.tag == 0) {
            // 播放完毕后如果还需正常 seek，需要做以下操作
            if (engine?.playbackState == TTVideoEnginePlaybackState.stopped) {
                engine?.play();
            }
            // currentTime 需要快进/快退到某个时间点
            engine?.setCurrentPlaybackTime(TimeInterval(sender.value), complete: { success in
                // seek 操作状态完成回调
                NSLog("VEVodPlayerAPIExample - seek complete \(success)");
            }, renderComplete: {
                // seek 渲染完成回调
                NSLog("VEVodPlayerAPIExample - seek render complete");
            })
        } else if (sender.tag == 2) {
            engine?.volume = CGFloat(sender.value);
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            // 从指定时间起播，需在 play 之前设置
            engine?.setOptionForKey(VEKKey.VEKKeyPlayerStartTime_CGFloat.rawValue, value:playStartTime);
            // 开始播放
            engine?.play();
        case 1:
            // 暂停播放
            engine?.pause();
        case 2:
            inputPlayStartTime();
        case 3:
            // 设置播放速度
            engine?.playbackSpeed = 0.5;
        case 4:
            // 设置播放速度
            engine?.playbackSpeed = 1.0;
        case 5:
            // 设置播放速度
            engine?.playbackSpeed = 1.5;
        case 6:
            // 设置播放速度
            engine?.playbackSpeed = 2.0;
        case 7:
            // 关闭循环播放
            engine?.looping = false;
        case 8:
            // 开启循环播放
            engine?.looping = true;
        case 9:
            // 关闭静音
            engine?.muted = false;
        case 10:
            // 开启静音
            engine?.muted = true;
        default:
            break;
        }
    }
}

extension BasicPlayerbackSwiftViewController: TTVideoEngineDelegate {
    // 异常播放结束回调。
    nonisolated func videoEngineDidFinish(_ videoEngine: TTVideoEngine, videoStatusException status: Int) {
        NSLog("VEVodPlayerAPIExample - videoEngineDidFinish, videoStatusException is \(status)");
    }
    
    /// 播放状态变更（播放/暂停等）
    nonisolated func videoEngine(_ videoEngine: TTVideoEngine, playbackStateDidChanged playbackState: TTVideoEnginePlaybackState) {
        NSLog("VEVodPlayerAPIExample - playbackStateDidChanged to \(playbackState.rawValue)");
    }
    
    /// 加载状态变更（控制loading视图显示/隐藏）
    nonisolated func videoEngine(_ videoEngine: TTVideoEngine, loadStateDidChanged loadState: TTVideoEngineLoadState) {
        /*
         - TTVideoEngineLoadStatePlayable: 隐藏loading视图
         - TTVideoEngineLoadStateStalled:  显示loading视图
         */
        NSLog("VEVodPlayerAPIExample - loadStateDidChanged to \(loadState.rawValue)");
    }
    
    /// 播放器初始化完成（即将开始播放）
    nonisolated func videoEnginePrepared(_ videoEngine: TTVideoEngine) {
        NSLog("VEVodPlayerAPIExample - videoEnginePrepared")
    }
    
    /// 视频首帧已渲染（可隐藏封面图）
    nonisolated func videoEngineReady(toDisPlay videoEngine: TTVideoEngine) {
        NSLog("VEVodPlayerAPIExample - videoEngineReadyToDisPlay")
        // 此处隐藏封面图，显示视频画面
    }
    
    /// 视频开始播放
    nonisolated func videoEngineReady(toPlay videoEngine: TTVideoEngine) {
        NSLog("VEVodPlayerAPIExample - videoEngineReadyToPlay")
    }
    
    /// SDK内部重试中（error为错误信息）
    nonisolated func videoEngine(_ videoEngine: TTVideoEngine, retryForError error: Error) {
        NSLog("VEVodPlayerAPIExample - videoEngine is retrying, error: \(error.localizedDescription)")
    }
    
    /// 视频发生卡顿（不包括Seek操作）
    nonisolated func videoEngineStalledExcludeSeek(_ videoEngine: TTVideoEngine) {
        NSLog("VEVodPlayerAPIExample - videoEngineStalledExcludeSeek")
    }
    
    /// 缓存命中通知（cacheSize > 0 表示命中预加载）
    nonisolated func videoEngine(_ videoEngine: TTVideoEngine, mdlKey key: String, hitCacheSize cacheSize: Int) {
        NSLog("VEVodPlayerAPIExample - mdl key = \(key), hitCacheSize = \(cacheSize)")
    }
    
    /// 用户主动停止播放完成
    nonisolated func videoEngineUserStopped(_ videoEngine: TTVideoEngine) {
        NSLog("VEVodPlayerAPIExample - videoEngineUserStopped")
    }
    
    /// 播放结束（error为空表示正常结束）
    nonisolated func videoEngineDidFinish(_ videoEngine: TTVideoEngine, error: Error?) {
        if let error = error {
            NSLog("VEVodPlayerAPIExample - videoEngineDidFinish with error: \(error.localizedDescription)")
        } else {
            NSLog("VEVodPlayerAPIExample - videoEngineDidFinish")
        }
    }
    
    /// 异步关闭播放器完成
    nonisolated func videoEngineCloseAysncFinish(_ videoEngine: TTVideoEngine) {
        NSLog("VEVodPlayerAPIExample - videoEngineCloseAysncFinish")
    }
}

// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  DirectUrlSubtitleSwiftViewController.swift
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/5/29.
//

import Foundation
import TTSDKFramework
import SnapKit

@objc(DirectUrlSubtitleSwiftViewController)
class DirectUrlSubtitleSwiftViewController: UIViewController, TTVideoEngineSubtitleDelegate {
    private var engine: TTVideoEngine?;
    private var subtitleInfoModel: TTVideoEngineSubDecInfoModel?;
    private var buttonNum = 0;
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel();
        label.textColor = .white;
        label.backgroundColor = UIColor(white: 0, alpha: 0.5);
        label.textAlignment = .center;
        label.numberOfLines = 0;
        label.font = .systemFont(ofSize: 20, weight: .medium);
        label.layer.cornerRadius = 4;
        label.clipsToBounds = true;
        return label;
    }();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        NSLog("VEVodPlayerAPIExample - DirectUrlSubtitleSwiftViewController");
        view.backgroundColor = .white;
        getSubtitleInfoModel();
        setupPlayerForSubtitle();
        setupViews();
        engine?.play();
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        engine?.playerView.removeFromSuperview();
        engine?.closeAysnc();
        engine = nil;
    }
    
    private func setupPlayerForSubtitle() {
        engine = TTVideoEngine(ownPlayer: true);
        
        // 配置播放源
        let videoModel = VEAPISwiftVideoModel.defaultVideoModel()[4];
        let videoUrl = videoModel.videoUrl;
        
        let urlSource = VEAPISwiftVideoModel.initDirectUrlSource(videoUrl);
        engine?.setVideoEngineVideoSource(urlSource);
        
        // 外挂字幕功能总开关，建议在设置 vid 之前调用
        engine?.setOptionForKey(VEKKey.VEKeyPlayerEnableSubThread_BOOL.rawValue, value: NSNumber(value: true));
        // 外挂字幕加载优化开关
        // NO: 关闭外挂字幕加载优化；YES: 开启外挂字幕加载优化
        engine?.setOptionForKey(VEKKey.VEKKeyPlayerSubtitleOptEnable_BOOL.rawValue, value: NSNumber(value: true));
        // 使用数据加载模块 MDL 加载外挂字幕，提升加载成功率
        // YES: 使用 MDL 加载外挂字幕
        // NO: 不使用 MDL 加载外挂字幕
        engine?.setOptionForKey(VEKKey.VEKKeySubTitleEnableMDL_BOOL.rawValue, value: NSNumber(value: true));
        // 展示字幕，推荐在播放前先开启一次，也支持在播放中设置，YES: 输出字幕；NO: 停止输出字幕
        engine?.setOptionForKey(VEKKey.VEKKeyPlayerSubEnabled_BOOL.rawValue, value: NSNumber(value: true));
        
        // 设置 DirectURL 模式下的字幕源
        engine?.subDecInfoModel = self.subtitleInfoModel;
        // 设置字幕回调
        engine?.subtitleDelegate = self;
    }
    
    private func setupViews() {
        guard let engineView = engine?.playerView else { return; }
        
        let topOffset = UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.height ?? 0);
        
        view.addSubview(engineView);
        engineView.snp.makeConstraints { make in
            make.top.equalTo(view).offset(topOffset);
            make.left.width.equalTo(view);
            make.height.equalTo(view.snp.width);
        };
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)));
        engineView.addGestureRecognizer(tapGesture);
        engineView.isUserInteractionEnabled = true;
        
        let subTitle = UILabel();
        subTitle.text = NSLocalizedString("show_subtitle_label", comment: "");
        view.addSubview(subTitle);
        subTitle.snp.makeConstraints { make in
            make.top.equalTo(engineView.snp.bottom).offset(3);
            make.left.equalTo(5);
            make.width.equalTo(300);
            make.height.equalTo(30);
        };
        
        view.addSubview(subtitleLabel);
        subtitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview();
            make.top.equalTo(subTitle.snp.bottom).offset(3);
            make.width.equalToSuperview().multipliedBy(0.8);
            make.height.equalTo(50);
        };
        
        let controlLabel = UILabel();
        controlLabel.text = NSLocalizedString("control_subtitle_label", comment: "");
        view.addSubview(controlLabel);
        controlLabel.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(3);
            make.left.equalTo(5);
            make.width.equalTo(300);
            make.height.equalTo(30);
        };
        
        let buttons = [NSLocalizedString("start_subtitle", comment: ""), NSLocalizedString("end_subtitle", comment: ""), NSLocalizedString("chinese_label", comment: ""), NSLocalizedString("english_label", comment: "")];
        createButtons(titles: buttons, width: 80, anchorView: controlLabel);
    }
    
    private func createButtons(titles: [String], width: CGFloat, anchorView: UIView) {
        for (index, title) in titles.enumerated() {
            let button = VEAPIButton(title: title);
            button.tag = buttonNum;
            buttonNum += 1;
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside);
            view.addSubview(button);
            
            button.snp.makeConstraints { make in
                make.top.equalTo(anchorView.snp.bottom).offset(3);
                make.left.equalTo(CGFloat(index) * (width + 5) + 3);
                make.width.equalTo(width);
                make.height.equalTo(35);
            };
        }
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let engine = engine else { return; }
        
        if engine.playbackState != .playing {
            engine.play();
        } else {
            engine.pause();
        }
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        guard let engine = engine else { return; }
        
        switch sender.tag {
        case 0:
            engine.setOptionForKey(VEKKey.VEKKeyPlayerSubEnabled_BOOL.rawValue, value: NSNumber(value: true));
        case 1:
            engine.setOptionForKey(VEKKey.VEKKeyPlayerSubEnabled_BOOL.rawValue, value: NSNumber(value: false));
            refreshContent("");
        case 2:
            if let subIDs = VEAPIVideoModel.defaultSubtitleSubIDs()[4] as? [String: NSNumber],
               let chineseID = subIDs["cmn-Hans-CN"] {
                engine.setOptionForKey(VEKKey.VEKeyPlayerSwitchSubtitleId_NSInteger.rawValue, value: chineseID);
            }
        case 3:
            if let subIDs = VEAPIVideoModel.defaultSubtitleSubIDs()[4] as? [String: NSNumber],
               let englishID = subIDs["eng-US"] {
                engine.setOptionForKey(VEKKey.VEKeyPlayerSwitchSubtitleId_NSInteger.rawValue, value: englishID);
            }
        default:
            break
        }
    }
    
    nonisolated private func refreshContent(_ content: String) {
        DispatchQueue.main.async {
            self.subtitleLabel.text = content;
            self.view.layoutIfNeeded();
        }
    }
    
    private func getSubtitleInfoModel() {
        /**
         json 字符串格式
         {\"list\"：[{\"sub_id\":-248462473,\"format\":\"webvtt\",\"language\":\"cmn-Hans-CN\",\"language_id\":1,\"url\":\"http://vodsdk-api-example.byte-test.com/0a10248c56c44c26b7269eef18e24a6f?auth_key=2063269808-ca6cd62edfbd4b10b52edee9c8db04b9-0-2f2e48450e52206c863cb38df2f14ffa&mime_type=text_plain\"}]}
         */
        let jsonString = VEAPISwiftVideoModel.defaultVideoModel()[4].subtitleModels;
        guard let jsonData = jsonString.data(using: .utf8) else {
            NSLog("VEVodPlayerAPIExample - JSON 字符串转换失败");
            return
        }
        do {
            guard let subtitleDict = try JSONSerialization.jsonObject(
                with: jsonData,
                options: []
            ) as? [String: Any] else {
                NSLog("VEVodPlayerAPIExample - JSON 解析结果类型不匹配");
                return
            }
            
            let subtitleModel = TTVideoEngineSubDecInfoModel(dictionary: subtitleDict);
            self.subtitleInfoModel = subtitleModel;
            
        } catch {
            NSLog("VEVodPlayerAPIExample - JSON 解析错误: \(error.localizedDescription)");
        }
    }
    
    // MARK: - TTVideoEngineSubtitleDelegate
    // 每行字幕信息回调。返回视频当前播放进度处的字幕内容。收到字幕信息后，您需要自行渲染字幕。
    // content：单行字幕内容
    // pts：时间戳
    nonisolated func videoEngine(_ videoEngine: TTVideoEngine, onSubtitleInfoCallBack content: String, pts: UInt) {
        // 刷新字幕
        refreshContent(content);
        NSLog("VEVodPlayerAPIExample - Subtitle - pts:\(pts), content:\(content)");
    }
    
    nonisolated func videoEngine(_ videoEngine: TTVideoEngine, onSubtitleInfoCallBack subInfo: TTVideoEngineSubInfo) {
        // subInfo.pts: 字幕开始显示的时间戳
        // subInfo.content： 字幕内容
        // subInfo.duration： 字幕要持续的时长。
        // 每行字幕信息回调，subInfo：TTVideoEngineSubInfo
        NSLog("VEVodPlayerAPIExample - Subtitle - pts:\(subInfo.pts), content:\(subInfo.content), duration:\(subInfo.duration)");
    }
    
    nonisolated func videoEngine(_ videoEngine: TTVideoEngine, onSubSwitchCompleted success: Bool, currentLangId: Int) {
        // 字幕切换完成，currentLangId：当前语言ID
        NSLog("VEVodPlayerAPIExample - Subtitle - switch to \(currentLangId).");
    }
    
    nonisolated func videoEngine(_ videoEngine: TTVideoEngine, onSubLoadFinished success: Bool, info: TTVideoEngineLoadInfo?) {
        // 当前字幕加载完成
        if !success {
            // 字幕加载失败。可移除字幕渲染或重新请求
            NSLog("VEVodPlayerAPIExample - Subtitle - load fail and code is \(info?.loadStageCode ?? -1)");
        } else {
            // 字幕加载成功。
            // info.firstPts 字幕首次出现的时间戳
            NSLog("VEVodPlayerAPIExample - Subtitle - load success and the first pts is \(info?.firstPts ?? -1)");
        }
    }
}

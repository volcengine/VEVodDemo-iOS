// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  DisplayModeSwiftViewController.swift
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/5/28.
//

import Foundation
import SnapKit
import TTSDKFramework

@objc(DisplayModeSwiftViewController)
class DisplayModeSwiftViewController: UIViewController {
    private var engine: TTVideoEngine?;
    private var buttonNum = 0;
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView();
        return view;
    }()
    private lazy var containView: UIView = {
        let view = UIView();
        return view;
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad();
        NSLog("VEVodPlayerAPIExample - DisplayModeSwiftViewController");
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
        setupScrollViews();
        setupPlayer();
        
        guard let engine = self.engine else {
            NSLog("VEVodPlayerAPIExample - engine is nil");
            return
        }
        let ratioLabel = UILabel();
        ratioLabel.text = NSLocalizedString("view_size_label", comment: "");
        containView.addSubview(ratioLabel)
        ratioLabel.snp.makeConstraints { make in
            make.top.equalTo(engine.playerView.snp.bottom).offset(3)
            make.left.equalToSuperview().offset(5)
            make.width.equalTo(300)
            make.height.equalTo(30)
        }
        let ratioTitles = ["1:2", "9:16", "3:4", "1:1", "4:3", "16:9", "2:1"]
        createButtons(titles: ratioTitles, width: 50, under: ratioLabel)
        
        let displayLabel = UILabel();
        displayLabel.text = NSLocalizedString("mode_label", comment: "");
        containView.addSubview(displayLabel)
        displayLabel.snp.makeConstraints { make in
            make.top.equalTo(ratioLabel.snp.bottom).offset(41)
            make.left.equalToSuperview().offset(5)
            make.width.equalTo(300)
            make.height.equalTo(30)
        }
        let displayTitles = ["AspectFit", "AspectFill", "Fill"]
        createButtons(titles: displayTitles, width: 90, under: displayLabel)
        
        containView.snp.makeConstraints { make in
            make.bottom.equalTo(displayLabel.snp.bottom).offset(70)
        }
    }
    
    private func setupScrollViews() {
        let topOffset = UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.height ?? 0);
        view.addSubview(scrollView);
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.snp.top).offset(topOffset);
            make.left.right.bottom.equalToSuperview();
        }
        
        scrollView.addSubview(containView);
        containView.snp.makeConstraints { make in
            make.edges.width.equalToSuperview();
        }
    }
    
    private func createButtons(titles: [String], width: CGFloat, under label: UIView) {
        for (index, title) in titles.enumerated() {
            let button = VEAPIButton(title: title)
            button.tag = buttonNum
            buttonNum += 1
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            containView.addSubview(button)
            
            button.snp.makeConstraints { make in
                make.top.equalTo(label.snp.bottom).offset(3)
                make.left.equalToSuperview().offset((width + 5) * CGFloat(index) + 3)
                make.width.equalTo(width)
                make.height.equalTo(35)
            }
        }
    }
    
    private func setupPlayer() {
        // 初始化播放器
        engine = TTVideoEngine(ownPlayer: true);
        
        guard let playerView = engine?.playerView else {
            NSLog("Player view initialization failed");
            return;
        }
        
        // 添加播放器视图
        containView.addSubview(playerView);
        playerView.backgroundColor = .gray;
        playerView.snp.makeConstraints { make in
            make.top.left.width.equalToSuperview();
            make.height.equalTo(containView.snp.width);
        }
        
        // 配置播放源
        let videoModel = VEAPISwiftVideoModel.defaultVideoModel()[0];
        let videoUrl = videoModel.videoUrl;
        
        let urlSource = VEAPISwiftVideoModel.initDirectUrlSource(videoUrl);
        engine?.setVideoEngineVideoSource(urlSource);
        engine?.play();
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        switch sender.tag {
        case 0: // 1:2
            remakeConstraints { make in
                make.height.equalTo(containView.snp.width).multipliedBy(2)
            }
            
        case 1: // 9:16
            remakeConstraints { make in
                make.height.equalTo(containView.snp.width).multipliedBy(16.0/9.0)
            }
            
        case 2: // 3:4
            remakeConstraints { make in
                make.height.equalTo(containView.snp.width).multipliedBy(4.0/3.0)
            }
            
        case 3: // 1:1
            remakeConstraints { make in
                make.height.equalTo(containView.snp.width)
            }
            
        case 4: // 4:3
            remakeConstraints { make in
                make.height.equalTo(containView.snp.width).multipliedBy(3.0/4.0)
            }
            
        case 5: // 16:9
            remakeConstraints { make in
                make.height.equalTo(containView.snp.width).multipliedBy(9.0/16.0)
            }
            
        case 6: // 2:1
            remakeConstraints { make in
                make.height.equalTo(containView.snp.width).multipliedBy(0.5)
            }
            
        case 7: // AspectFit
            engine?.setOptionForKey(VEKKey.VEKKeyViewScaleMode_ENUM.rawValue, value: TTVideoEngineScalingMode.aspectFit.rawValue)
            
        case 8: // AspectFill
            engine?.setOptionForKey(VEKKey.VEKKeyViewScaleMode_ENUM.rawValue, value: TTVideoEngineScalingMode.aspectFill.rawValue)
            
        case 9: // Fill
            engine?.setOptionForKey(VEKKey.VEKKeyViewScaleMode_ENUM.rawValue, value: TTVideoEngineScalingMode.fill.rawValue)
            
        default:
            break
        }
    }
    
    private func remakeConstraints(_ maker: (ConstraintMaker) -> Void) {
        engine?.playerView.snp.remakeConstraints { make in
            make.top.left.width.equalToSuperview()
            maker(make)
        }
        UIView.animate(withDuration: 0.3) {
            self.containView.layoutIfNeeded()
        }
    }
}

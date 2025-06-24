// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  ShortVideoSwiftTableViewCell.swift
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/6/23.
//

import Foundation
import TTSDKFramework
import SnapKit
import SDWebImage

class ShortVideoSwiftTableViewCell: UITableViewCell, TTVideoEngineDelegate {
    nonisolated func videoEngineUserStopped(_ videoEngine: TTVideoEngine) {
        NSLog("VEVodPlayerAPIExample - videoEngineUserStopped");
    }
    
    nonisolated func videoEngineDidFinish(_ videoEngine: TTVideoEngine, error: (any Error)?) {
        NSLog("VEVodPlayerAPIExample - videoEngineDidFinish");
    }
    
    nonisolated func videoEngineDidFinish(_ videoEngine: TTVideoEngine, videoStatusException status: Int) {
        NSLog("VEVodPlayerAPIExample - videoEngineDidFinish");
    }
    
    nonisolated func videoEngineCloseAysncFinish(_ videoEngine: TTVideoEngine) {
        NSLog("VEVodPlayerAPIExample - videoEngineCloseAysncFinish");
    }
    
    nonisolated func videoEngine(_ videoEngine: TTVideoEngine, mdlKey: String, hitCacheSze cacheSize: Int) {
        //
        NSLog("VEVodPlayerAPIExample - mdl key = \(mdlKey) - hitCacheSize = \(cacheSize)");
    }
    
    private var engine: TTVideoEngine?
    private var sourceUrl: String?
    private var coverUrl: String?
    private var urlSource: TTVideoEngineUrlSource?
    
    private lazy var coverView: UIImageView = {
        let iv = UIImageView();
        iv.contentMode = .scaleAspectFit;
        iv.clipsToBounds = true;
        return iv;
    }();
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier);
        setupCell();
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder);
        setupCell();
    }
    
    private func setupCell() {
        selectionStyle = .none;
        backgroundColor = .black;
        contentView.addSubview(coverView);
        coverView.snp.makeConstraints { make in
            make.edges.equalToSuperview();
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse();
        coverView.image = nil;
        closeAsync();
        coverView.isHidden = false;
    }
    
    func configure(source: String, cover: String) {
        sourceUrl = source;
        coverUrl = cover;
        urlSource = VEAPIMediaSource.initDirectUrlSource(source);
        setupVideoEngine();
    }
    
    private func setupVideoEngine() {
        guard let urlSource = urlSource else { return; }
        // 尝试获取预渲染播放器
        if let preRenderEngine = TTVideoEngine.getPreRenderFinishedVideoEngine(withVideoSource: urlSource) {
            engine = preRenderEngine;
            engine?.delegate = self;
            coverView.isHidden = true;
            setupPlayerView();
            NSLog("VEVodPlayerAPIExample - 使用预渲染播放器视图");
        } else {
            coverView.isHidden = false;
            coverView.sd_setImage(with: URL(string: coverUrl ?? ""));
            NSLog("VEVodPlayerAPIExample - 使用封面图");
        }
    }
    
    func play() {
        coverView.isHidden = true
        guard let urlSource = urlSource else { return; }
        // 尝试获取预渲染播放器
        if let preRenderEngine = TTVideoEngine.getPreRenderFinishedVideoEngine(withVideoSource: urlSource) {
            engine = preRenderEngine;
            engine?.delegate = self;
            setupPlayerView();
            NSLog("VEVodPlayerAPIExample - 使用预渲染播放器");
        } else {
            engine = TTVideoEngine(ownPlayer: true);
            engine?.delegate = self;
            engine?.setVideoEngineVideoSource(urlSource);
            setupPlayerView();
            NSLog("VEVodPlayerAPIExample - 使用新建播放器");
        }
        engine?.play();
    }
    
    func pause() {
        engine?.pause();
    }
    
    func closeAsync() {
        // 释放播放器
        engine?.playerView.removeFromSuperview();
        engine?.closeAysnc();
        engine = nil;
    }
    
    private func setupPlayerView() {
        guard let playerView = engine?.playerView else { return; }
        
        playerView.removeFromSuperview()
        contentView.insertSubview(playerView, aboveSubview: coverView)
        
        playerView.snp.remakeConstraints { make in
            make.edges.equalToSuperview();
        }
        coverView.isHidden = true;
        playerView.isHidden = false;
    }
}

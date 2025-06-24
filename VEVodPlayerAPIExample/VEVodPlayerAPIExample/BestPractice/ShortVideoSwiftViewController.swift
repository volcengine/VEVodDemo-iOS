// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  ShortVideoSwiftViewController.swift
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/6/23.
//

import Foundation
import TTSDKFramework
import SnapKit

@objc(ShortVideoSwiftViewController)
class ShortVideoSwiftViewController: UIViewController {
    private var sources: [VEAPIVideoModel] = VEAPISwiftVideoModel.defaultVideoModel();
    private var currentPlayIndexPath: IndexPath?;
    private var currentPlayCell: ShortVideoSwiftTableViewCell?;
    private lazy var tableView: UITableView = {
        let view = UITableView();
        view.register(ShortVideoSwiftTableViewCell.self, forCellReuseIdentifier: "VEVodPlayerAPIExampleShortVideoForSwift");
        view.delegate = self;
        view.dataSource = self;
        view.backgroundColor = .black;
        view.isPagingEnabled = true;
        view.showsVerticalScrollIndicator = false;
        view.separatorStyle = .none;
        if #available(iOS 11.0, *) {
            view.contentInsetAdjustmentBehavior = .never;
        }
        return view;
    }();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        NSLog("VEVodPlayerAPIExample - ShortVideoSwiftViewController");
        let appearance = UINavigationBarAppearance();
        appearance.configureWithOpaqueBackground();
        appearance.backgroundColor = .clear;
        appearance.shadowColor = .clear;
        navigationController?.navigationBar.standardAppearance = appearance;
        navigationController?.navigationBar.scrollEdgeAppearance = appearance;
        
        view.addSubview(tableView);
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview();
        }
        
        startEngineStrategy();
        tableView.reloadData();
        playVideo(at: IndexPath(row: 0, section: 0));
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        currentPlayCell?.closeAsync();
        TTVideoEngine.clearAllEngineStrategy();
    }
    
    private func startEngineStrategy() {
        // 开启预加载策略，建议在进入短视频页面开启
        TTVideoEngine.enable(TTVideoEngineStrategyType.preload, scene: TTVEngineStrategySceneSmallVideo);
        // 开启预渲染策略，建议在进入短视频页面开启
        TTVideoEngine.enable(TTVideoEngineStrategyType.preRender, scene: TTVEngineStrategySceneSmallVideo);
        let mediaSources: [TTVideoEngineMediaSource] = VEAPISwiftVideoModel.covertVideoModelsToTTVideoEngineSources(self.sources);
        TTVideoEngine.setStrategyVideoSources(mediaSources);
    }
    
    private func playVideo(at indexPath: IndexPath) {
        guard indexPath.row < sources.count,
            let cell = tableView.cellForRow(at: indexPath) as? ShortVideoSwiftTableViewCell,
            currentPlayIndexPath != indexPath
        else { return }
        
        currentPlayCell?.closeAsync()
        cell.play()
        currentPlayCell = cell
        currentPlayIndexPath = indexPath
    }
    
    private func currentVisibleIndexPath() -> IndexPath? {
        let visibleRect = CGRect(origin: tableView.contentOffset, size: tableView.frame.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        return tableView.indexPathForRow(at: visiblePoint)
    }
}

// MARK: - UITableView 协议实现
extension ShortVideoSwiftViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sources.count;
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.height;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let source = sources[indexPath.row];
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VEVodPlayerAPIExampleShortVideoForSwift", for: indexPath) as? ShortVideoSwiftTableViewCell else {
            let newCell = ShortVideoSwiftTableViewCell();
            newCell.configure(source: source.videoUrl, cover: source.coverUrl);
            newCell.backgroundColor = .black;
            return newCell;
        };
        cell.configure(source: source.videoUrl, cover: source.coverUrl);
        cell.backgroundColor = .black;
        return cell;
    }
    
    // MARK: - 滚动控制
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let indexPath = currentVisibleIndexPath() else { return }
        playVideo(at: indexPath)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate, let indexPath = currentVisibleIndexPath() else { return }
        playVideo(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let customCell = cell as? ShortVideoSwiftTableViewCell else { return; }
        let source = sources[indexPath.row];
        customCell.configure(source: source.videoUrl, cover: source.coverUrl);
    }
}

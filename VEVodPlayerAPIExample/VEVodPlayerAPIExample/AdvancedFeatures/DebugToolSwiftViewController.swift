// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  DebugToolSwiftViewController.swift
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/6/4.
//

import Foundation
import TTSDKFramework
import SnapKit

@objc(DebugToolSwiftViewController)
class DebugToolSwiftViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad();
        NSLog("VEVodPlayerAPIExample - DebugToolSwiftViewController");
        self.view.backgroundColor = .white;
        let vc: VidSourceSwiftViewController = VidSourceSwiftViewController();
        self.addChild(vc);
        vc.view.frame = self.view.bounds;
        self.view.addSubview(vc.view);
        vc.didMove(toParent: self);
        showDebugTool();
        if (TTVideoEngine.debugToolIsShowing()) {
            NSLog("VEVodPlayerAPIExample - debugTool is showing");
        } else {
            NSLog("VEVodPlayerAPIExample - debugTool is not showing");
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        removeDebugTool();
        super.viewWillDisappear(animated);
    }
    
    // 添加展示 debug 工具
    private func showDebugTool() {
        // 强烈建议只在 Debug 模式下添加 debug 工具
        let topCat: CGFloat = 70;
        let width: CGFloat = self.view.bounds.width;
        let height: CGFloat = self.view.bounds.height - 100;
        TTVideoEngine.showDebugTool(self.view, in: CGRect(x: 0, y: topCat, width: width, height: height))
    }
    
    // 不使用时，移除 debug 工具
    private func removeDebugTool() {
        TTVideoEngine.removeDebugTool();
    }
}

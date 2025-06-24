// Copyright (c) 2025 Beijing Volcano Engine Technology Co., Ltd.
// SPDX-License-Identifier: MIT
//
//  VidSourceSwiftViewController.swift
//  VEVodPlayerAPIExample
//
//  Created by ByteDance on 2025/5/27.
//

import Foundation
import TTSDKFramework
import SnapKit

@objc(VidSourceSwiftViewController)
class VidSourceSwiftViewController : UIViewController {
    private var engine: TTVideoEngine?;
    private var needToResume: Bool = false;
    private var options: [String] = ["SD", "HD", "FullHD", "HD_H"];
    private lazy var textField: UITextField = {
        let view = UITextField();
        view.borderStyle = .roundedRect
        return view;
    }();
    
    override func viewDidLoad() {
        super.viewDidLoad();
        NSLog("VEVodPlayerAPIExample - VidSourceSwiftViewController");
        setupVideoEngine();
        setupUI();
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
        setupResolutionSelector();
    }
    
    private func setupVideoEngine() {
        let topOffset = UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.height ?? 0)
    
        // 初始化播放器
        engine = TTVideoEngine(ownPlayer: true);
        
        guard let playerView = engine?.playerView else {
            NSLog("Player view initialization failed");
            return
        }
        
        // 添加播放器视图
        view.addSubview(playerView);
        playerView.snp.makeConstraints { make in
            make.top.equalTo(view).offset(topOffset)
            make.left.right.equalTo(view)
            make.height.equalTo(view).multipliedBy(0.8)
        }
        
        // 开启优化前后台切换卡顿开关
        engine?.setOptionForKey(VEKKey.VEKKeyIsDecodeMalFunctionErrorIgnore.rawValue, value: NSNumber(value: 1));
        // 开启优化前后台切换跳帧开关
        engine?.setOptionForKey(VEKKey.VEKKeyPlayerIsIgnoreTestSizeOnPause.rawValue, value: NSNumber(value: 1));
        
        // 配置 vid 播放源
        let videoModel = VEAPISwiftVideoModel.defaultVideoModel()[1];
        let vid = videoModel.vid;
        let playAuthToken = videoModel.playAuthToken;
        let resolution: TTVideoEngineResolutionType = .typeFullHD;
        
        let urlSource = VEAPISwiftVideoModel.initVidSource(vid: vid, playAuthToken: playAuthToken, resolution: resolution);
        engine?.setVideoEngineVideoSource(urlSource);
        engine?.delegate = self;
        engine?.play();
    }
    
    private func setupResolutionSelector() {
        guard let engine = self.engine else {
            NSLog("VEVodPlayerAPIExample - engine is nil");
            return
        }
        let label = UILabel();
        label.text = NSLocalizedString("set_resolution", comment: "");
        view.addSubview(label);
        label.snp.makeConstraints { make in
            make.top.equalTo(engine.playerView.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(5)
            make.width.equalTo(110)
            make.height.equalTo(40)
        }
        
        textField.placeholder = currentResolutionPlaceholder()
        view.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.top.equalTo(engine.playerView.snp.bottom)
            make.left.equalTo(label.snp.right)
            make.width.equalTo(150)
            make.height.equalTo(40)
        }
        
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        textField.inputView = picker
    }
    
    private func currentResolutionPlaceholder() -> String {
        // 获取视频正在播放的清晰度
        switch engine?.currentResolution {
            case .typeSD: return "SD"
            case .typeHD: return "HD"
            case .typeFullHD: return "FullHD"
            case .typeHD_H: return "HD_H"
            default: return "未知"
        }
    }
    
    @objc func handleResignActive(_ notification: Notification) {
        NSLog("VEVodPlayerAPIExample - applicationWillResignActive from VidSourceSwiftViewController");
        // 即将进入后台时，若视频正在播放，则需要暂停
        if (self.engine?.playbackState == .playing) {
            self.engine?.pause();
            self.needToResume = true;
        } else {
            self.needToResume = false;
        }
    }
    
    @objc func handleBecomeActive(_ notification: Notification) {
        NSLog("VEVodPlayerAPIExample - applicationDidBecomeActive in VidSourceSwiftViewController");
        // 从后台回复后，若视频之前是播放状态，则需要恢复播放
        if (self.needToResume) {
            self.engine?.play();
        }
    }
}

extension VidSourceSwiftViewController: TTVideoEngineDelegate {
    nonisolated func videoEngineUserStopped(_ videoEngine: TTVideoEngine) {
        // 用户主动停止播放完成
        NSLog("VEVodPlayerAPIExample - videoEngineUserStopped");
    }
    
    nonisolated func videoEngineDidFinish(_ videoEngine: TTVideoEngine, error: (any Error)?) {
        // 播放结束（error为空表示正常结束
        if let error = error {
            NSLog("VEVodPlayerAPIExample - videoEngineDidFinish with error: \(error.localizedDescription)")
        } else {
            NSLog("VEVodPlayerAPIExample - videoEngineDidFinish")
        }
    }
    
    nonisolated func videoEngineDidFinish(_ videoEngine: TTVideoEngine, videoStatusException status: Int) {
        // 异常播放结束回调。
        NSLog("VEVodPlayerAPIExample - videoEngineDidFinish, videoStatusException is \(status)");
    }
    
    nonisolated func videoEngineCloseAysncFinish(_ videoEngine: TTVideoEngine) {
        // 异步关闭播放器完成
        NSLog("VEVodPlayerAPIExample - videoEngineCloseAysncFinish");
    }
    
    nonisolated func videoEngine(_ videoEngine: TTVideoEngine, fetchedVideoModel videoModel: TTVideoEngineModel) {
        // 获取视频点播服务下发的清晰度数组，可用于清晰度列表展示
        let allResolutions = videoEngine.supportedResolutionTypes();
        NSLog("VEVodPlayerAPIExample - (in delegate) support resolutions are: \(allResolutions ?? [-1])");
    }
}

extension VidSourceSwiftViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        options[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textField.text = options[row]
        textField.resignFirstResponder()
        
        let resolutionType: TTVideoEngineResolutionType = {
            switch row {
            case 0: return .typeSD
            case 1: return .typeHD
            case 2: return .typeFullHD
            case 3: return .typeHD_H
            default: return .typeSD
            }
        }()
        
        // 切换视频清晰度
        engine?.configResolution(resolutionType) { [weak self] success, error, resolutionType in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if success {
                    NSLog("VEVodPlayerAPIExample - resolution switch successfully to \(resolutionType)");
                    self.textField.placeholder = self.currentResolutionPlaceholder();
                } else {
                    NSLog("VEVodPlayerAPIExample - resolution switch to \(resolutionType) failed with error: \(error?.localizedDescription ?? "未知错误")")
                }
            }
        }
    }
}

## VEVodPlayerAPIExample 介绍

提供火山引擎播放器 SDK API 示例代码，旨在示例播放器 SDK 的使用方式，帮助您快速熟悉 API 加速完成集成工作，包括基础功能、最佳实践等，后续会持续迭代。


## 目录结构说明

```
├─ VEVodPlayerAPIExample 
└── VEVodPlayerAPIExample
    ├── BestPractice // 最佳实践
    ├── QuickStart // 快速开始
    ├── AdvancedFeatures // 进阶功能
    ├── BasicFeatures // 基础功能
        ...
```

## 示例功能

### 快速开始
- [初始化 SDK 示例](VEVodPlayerAPIExample/InitSDKExample.m)：展示播放器 SDK 初始化流程；
- [Vid 源示例](VEVodPlayerAPIExample/QuickStart/VidSourceOCViewController.m)：展示 Vid 播放源播放流程，清晰度获取和选择；
- [Direct URL 示例](VEVodPlayerAPIExample/QuickStart/DirectUrlSourceOCViewController.m)：展示 Direct Url 播放源播放流程；

### 基本功能
- [基础播放示例](VEVodPlayerAPIExample/BasicFeatures/BasicPlaybackOCViewController.m)：展示播放控制、音量调节、网速获取等 API 使用方式；
- [显示模式示例](VEVodPlayerAPIExample/BasicFeatures/DisplayModeOCViewController.m)：展示 View 比例与视频比例不一致时，如何使用显示模式 API；
- [清除视频缓存示例](VEVodPlayerAPIExample/VEAPIVideoModel/VEAPIVideoModel.m)

### 最佳实践
- [抖音同款短视频最佳实践示例](VEVodPlayerAPIExample/BestPractice/ShortVideoOCViewController.m)：展示预加载+预渲染策略、播放提前、播放器异步调用、设置封面图等最佳实践策略；

### 进阶功能
- [Debug 工具示例](VEVodPlayerAPIExample/AdvancedFeatures/DebugToolOCViewController.m)：展示 Debug 工具的集成；
- [Direct URL 字幕示例](VEVodPlayerAPIExample/AdvancedFeatures/DirectUrlSubtitleOCViewController.m)：展示 DirectUrl 字幕，字幕语言切换；
- [Vid 字幕示例](VEVodPlayerAPIExample/AdvancedFeatures/VidSubtitleOCViewController.m)：展示 Vid 字幕，字幕语言切换；

## VOLCDemo运行

1. 进入 VEVodDemo-iOS/VEVodPlayerAPIExample 文件夹
2. 执行 pod install
3. 打开 VEVodPlayerAPIExample.xcworkspace 编译运行

**注意：**
<b>Demo 需要设置 AppId 和 License 才能成功运行，否则会抛出异常。</b> 请联系火山引擎商务获取体验 License 文件和 AppId。获取到 License 文件后请将 License 导入到工程中。

设置方式：
> 修改 [AppDelegate.m](VEVodPlayerAPIExample/AppDelegate.m) 文件
```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ...
    /// appid 和 license 不能为空，请到控制台申请后设置继续使用
    /// licesne 和 bundle identifier 一一对应，
    NSString *appId = @""; 
    NSString *licenseName = @"";
    ...
}
```

### 更多集成相关文档链接
- [集成准备](https://www.volcengine.com/docs/4/65775)
- [快速开始](https://www.volcengine.com/docs/4/65777)
- [基础功能接入](https://www.volcengine.com/docs/4/65779)
- [高级功能接入](https://www.volcengine.com/docs/4/67626)
- [预加载功能接入](https://www.volcengine.com/docs/4/65780)
- [控件层使用](https://bytedance.feishu.cn/docx/doxcnqF1Y9NIzOQH0m8OVQ0cPFo)
   - [快速开始](https://bytedance.feishu.cn/docx/doxcnMlusNTzjPb7jn2wMf1s7oe)
- [短视频场景封装层使用](https://bytedance.feishu.cn/docx/doxcnprOaYpOREMnnW8U2mxGajb)


## ChangeLog
链接：https://www.volcengine.com/docs/4/66438



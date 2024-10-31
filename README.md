## VOLCDemo介绍

1. VOLCDemo基于TTSDK点播SDK开发，目前完成了短、中、长等场景的视频基础能力展示。并提供了一些示例使用方式和工具层，后续会持续迭代。
2. 通过展示各种场景化解决方案来协助业务侧快速完成各类视频业务的快速搭建。
3. 新版本新增短剧场景示例。


## 目录结构说明

```
├─ VOLCDemo 
└── VOLCDemo
    ├── Base    // AppDelegate等App基本文件
└── Pods
    ├── TTSDK   // 火山引擎SDK（点播SDK载体）
        ...
    ├── VEVodMain           // App入口（VEMainViewController）
    ├── VEBaseKit           // 基础组件
    ├── VEPlayerKit         // 点播播放器控件
    ├── VEPlayerUIModule    // 点播UI控件封装层
    ├── VESceneModule       // 场景模块（短、中、长视频模块示例, 新版本新增短剧场景）    
```


## VOLCDemo运行

1. 进入 VEVodDemo-iOS/VOLCDemo 文件夹
2. 执行 pod install
3. 打开 VOLCDemo.xcworkspace 编译运行

**注意：**
<b>Demo 需要设置 AppId 和 License 才能成功运行，否则会抛出异常。</b> 请联系火山引擎商务获取体验 License 文件和 AppId。获取到 License 文件后请将 License 导入到工程中。

设置方式：
> 修改 AppDelegate
```objective-c
- (void)initTTSDK {

    /// appid 和 license 不能为空，请到控制台申请后设置继续使用
    /// licesne 和 bundle identifier 一一对应，
    NSString *appId = @""; 
    NSString *licenseName = @"";
    
    /// initialize ttsdk, configure Liscene ，this step cannot be skipped !!!!!
    TTSDKConfiguration *configuration = [TTSDKConfiguration defaultConfigurationWithAppID:appId licenseName:licenseName];
    /// 播放器CacheSize，默认100M，建议设置 300M
    TTSDKVodConfiguration *vodConfig = [[TTSDKVodConfiguration alloc] init];
    vodConfig.cacheMaxSize = 300 * 1024 * 1024; // 300M
    configuration.vodConfiguration = vodConfig;
    [TTSDKManager startWithConfiguration:configuration];
}
```

## TTSDK点播SDK 集成方式

### CocoaPods集成
1. 添加pod依赖
```
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/volcengine/volcengine-specs.git'

platform :ios, '11.0'

target 'VOLCDemo' do
  
  #这里需要明确指定使用 subspecs => Player-SR
  #可在 ChangeLog 获取版本号，推荐使用最新版本
  pod 'TTSDKFramework', 'x.x.x.x-premium', :subspecs => ['Player-SR']

end
```

2. 执行 pod install


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



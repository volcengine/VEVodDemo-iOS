## VOLCDemo介绍

VOLCDemo基于TTSDK点播SDK构建，当前版本以小视频场景演示，后续会持续迭代，短视频、长视频场景的使用；
希望帮助业务侧快速集成的点播模块，通过迭代短视频、小视频、长视频等场景帮助业务侧快速实现接入最佳实践；



## 目录结构说明

```
├─ TTSDK 
|  ├─ TTSDKFramework-1.17.2.3-premium-ta.zip  // 解压后是高级版动态库
|  ├─ TTSDKFramework-1.17.2.3-standard-ta.zip // 解压后是基础版动态库
├─ VOLCDemo 
└── VOLCDemo
    ├── Base    // Appdelegate
    ├── Common  // 通用组件
    ├── Module  // 实现模块：小视频等
    └── Utils   // 工具类
```



## VOLCDemo运行

1. 进入 VOLCDemo/VOLCDemo 文件夹
2. 执行 pod install
3. 打开 VOLCDemo.xcworkspace 编译运行



## TTSDK点播SDK 集成方式

### 方式一：CocoaPods集成【推荐】
1. 添加pod依赖
```
source 'https://github.com/volcengine/volcengine-specs.git'
pod 'TTSDK', 'x.x.x.x', :subspecs => [ # 推荐使用最新稳定版，具体版本号请参考最下方的ChangeLog 
  'Player',   # 点播SDK
]
```

2. 执行 pod install
3. import <TTSDK/TTVideoEngineHeader.h>


### 方式二：动态库方式手动集成
我们强烈推荐使用CocoaPods在线方式集成方式，但从业务测反馈业务侧接入时可能三方库存在冲突问题，这时候需要使用动态库方式手动集成；
- [手动集成文档](https://www.volcengine.com/docs/4/65775#%E6%96%B9%E6%B3%95%E4%BA%8C%EF%BC%9A%E6%89%8B%E5%B7%A5%E9%9B%86%E6%88%90)


### 更多集成相关文档链接
- [集成准备](https://www.volcengine.com/docs/4/65775)
- [快速开始](https://www.volcengine.com/docs/4/65777)
- [基础功能接入](https://www.volcengine.com/docs/4/65779)
- [高级功能接入](https://www.volcengine.com/docs/4/67626)
- [预加载功能接入](https://www.volcengine.com/docs/4/65780)




## ChangeLog

### Version 基础版：1.18.2.4-standard；高级版：1.18.2.4-premium（推荐使用） #
2021.07.26

New Features:
license过期后，支持回退至系统播放器
支持vid播放方式下的h265/h264的软硬解灵活配置
蒙版弹幕支持以dir_url方式设置蒙版url
支持音视频下载缓存至手机本地的功能
其它bugfix


### Version 基础版：1.18.1.3-standard；高级版：1.18.1.3-premium #
2021.07.12

New Features:
支持对接火山引擎的httpdns服务
倍速播放支持3倍速
静态库解决符号库冲突的问题
其它bugfix


### Version 基础版：1.17.2.3-standard；高级版：1.17.2.3-premium（推荐使用） 
2021.06.28

New Features:
1. 支持外挂字幕，支持全链路方案对接和纯客户端方案对接
2. 支持dir_url播放方式下的h265/h264的软硬解灵活配置
3. 上传SDK支持素材上传

### Version 基础版：1.17.1.2-standard；高级版：1.17.1.2-premium 
2021.06.15

New Features:
1. 提供 httpdns 接口
2. 提供获取实时下载网速接口
3. FFmpeg 支持本地 m3u8 中的 http 协议播放


### Version 基础版：1.16.2.2-standard；高级版：1.16.2.2-premium 
2021.05.31

Bug Fix:
1. 修复蒙版弹幕相关bug


### Version 基础版：1.16.1.5-standard；高级版：1.16.1.5-premium 
2021.05.17

New Features:
1. 支持蒙版弹幕


### Version 基础版：1.15.2.2-standard；高级版：1.15.2.2-premium 
2021.04.27

New Features:
1. h265 接口改造


### Version 基础版：1.14.0.9-standard；高级版：1.14.0.9-premium 
2021.04.13

New Features:
1. SDK 进行基础版、高级版和增值服务拆分，各版的功能说明请参考点播 SDK 介绍。
2. License 鉴权全面升级为 License 2.0，支持 License 变更/续期和在线更新.
3. License 2.0 介绍请参考应用管理；
4. 新用户 SDK 集成请参考集成准备 ；
5. 老用户 SDK 及 License 升级请参考License 2.0 升级说明。



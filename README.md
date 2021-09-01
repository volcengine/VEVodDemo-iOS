## VOLCDemo介绍

VOLCDemo基于TTSDK点播SDK构建，当前版本以小视频场景演示，后续会持续迭代，短视频、长视频场景的使用；
希望帮助业务侧快速集成的点播模块，通过迭代短视频、小视频、长视频等场景帮助业务侧快速实现接入最佳实践；



## 目录结构说明

```
├─ TTSDK 
|  ├─ TTSDKFramework-x.x.x.x-premium-ta.zip  // 解压后是高级版动态库
|  ├─ TTSDKFramework-x.x.x.x-standard-ta.zip // 解压后是基础版动态库
├─ VOLCDemo 
└── VOLCDemo
    ├── Base    // Appdelegate
    ├── Common  // 通用组件
    ├── Module  // 实现模块：小视频等
    └── Utils   // 工具类
```



## VOLCDemo运行

1. 进入 VEVodDemo-iOS/VOLCDemo 文件夹
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


#### Version 基础版：1.19.2.1-standard；高级版：1.19.2.1-premium（推荐使用）
2021.08.23

New Features:
bugfix

#### Version 基础版：1.19.1.1-standard；高级版：1.19.1.1-premium 
2021.08.10

New Features:
logcat支持查看license 2.0相关信息
和VESDK、CVSDK冲突依赖的问题修复 (boringssl)
支持画中画小窗播放
其它bugfix

#### Version 基础版：1.18.2.4-standard；高级版：1.18.2.4-premium #
2021.07.26

New Features:
license过期后，支持回退至系统播放器
支持vid播放方式下的h265/h264的软硬解灵活配置
蒙版弹幕支持以dir_url方式设置蒙版url
支持音视频下载缓存至手机本地的功能
其它bugfix


- [更多版本](https://www.volcengine.com/docs/4/66438)



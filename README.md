## VOLCDemo介绍

VOLCDemo基于TTSDK点播SDK构建，当前版本以小视频场景演示，后续会持续迭代，短视频、长视频场景的使用；
目标帮助业务侧快速集成的点播模块，通过迭代短视频、小视频、长视频等场景帮助业务侧快速实现接入最佳实践；

TTSDK v_1.23.1.4 版本增加播放器策略模块，一期上线小视频策略：通用策略、预加载、预渲染；




## 目录结构说明

```
├─ TTSDK 
|  ├─ TTSDKFramework-x.x.x.x-premium-ta.zip  // 解压后是高级版动态库
|  ├─ TTSDKFramework-x.x.x.x-standard-ta.zip // 解压后是基础版动态库
├─ VOLCDemo 
└── VOLCDemo
    ├── Base    // Appdelegate
    ├── Player  // 播放器
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
- [控件层使用](https://bytedance.feishu.cn/docx/doxcnqF1Y9NIzOQH0m8OVQ0cPFo)




## ChangeLog
链接：https://www.volcengine.com/docs/4/66438



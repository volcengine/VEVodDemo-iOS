## VOLCDemo介绍

VOLCDemo基于TTSDK点播SDK构建，当前版本以小视频场景演示，后续会持续迭代，短视频、长视频场景的使用；
目标帮助业务侧快速集成的点播模块，通过迭代短视频、小视频、长视频等场景帮助业务侧快速实现接入最佳实践；

## 目录结构说明

```
├─ TTSDK 
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

### 方式一：CocoaPods集成静态库
1. 添加pod依赖
```
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/volcengine/volcengine-specs.git'

platform :ios, '9.0'

target 'VOLCDemo' do
  
  #这里需要明确指定使用 subspecs => Player
  #可在 ChangeLog 获取版本号，推荐使用最新版本
  pod 'TTSDK', 'x.x.x.x-premium', :subspecs => ['Player']

end
```

2. 执行 pod install

### 方式二：CocoaPods集成动态库
1. 添加pod依赖
```
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/volcengine/volcengine-specs.git'

platform :ios, '9.0'

target 'VOLCDemo' do
  
  #添加TTSDKFramework动态库，版本号同静态库版本号
  pod 'TTSDKFramework', 'x.x.x.x-premium'
  
  #添加日志上报SDK，用于点播日志上传
  pod 'RangersAppLog', '6.9.1', :subspecs =>['Core','Log','Host/CN']

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


## ChangeLog
链接：https://www.volcengine.com/docs/4/66438



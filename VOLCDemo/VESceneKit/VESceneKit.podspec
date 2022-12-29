Pod::Spec.new do |s|
  s.name = "VESceneKit"
  s.version = "1.0.0"
  s.summary = "火山引擎点播短视频场景滑动组件"
  s.description = "火山引擎点播短视频场景滑动组件"
  s.homepage = "https://www.volcengine.com"
  s.license = 'MIT'
  s.author = { "zhaoxiaoyu" => "zhaoxiaoyu.realxx@bytedance.com" }
  s.source = { :path => './Classes' }

  s.platform = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'Classes/*'
  s.public_header_files = 'Classes/*.{h}'

  s.dependency 'Masonry'

end

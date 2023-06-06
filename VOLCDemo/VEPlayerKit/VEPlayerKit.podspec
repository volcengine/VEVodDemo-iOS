Pod::Spec.new do |s|
  s.name = "VEPlayerKit"
  s.version = "1.0.0"
  s.summary = "火山引擎点播播放器封装层"
  s.description = "火山引擎点播播放器封装层"
  s.homepage = "https://www.volcengine.com"
  s.license = 'MIT'
  s.author = { "zhaoxiaoyu" => "zhaoxiaoyu.realxx@bytedance.com" }
  s.source = { :path => './Classes' }

  s.platform = :ios, '9.0'
  s.requires_arc = true

  s.source_files = 'Classes/*'
  s.public_header_files = 'Classes/*.{h}'

  s.dependency 'TTSDK/Player', '1.37.3.8-premium'
  s.dependency 'Masonry'
  s.dependency 'SDWebImage'
  
end

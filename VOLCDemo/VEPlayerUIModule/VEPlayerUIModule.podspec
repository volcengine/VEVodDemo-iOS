Pod::Spec.new do |s|
  s.name = "VEPlayerUIModule"
  s.version = "1.0.0"
  s.summary = "火山引擎点播UI控件层"
  s.description = "火山引擎点播UI控件层"
  s.homepage = "https://www.volcengine.com/docs/4/2695"
  s.license = 'MIT'
  s.author = { "zhaoxiaoyu" => "zhaoxiaoyu.realxx@bytedance.com" }
  s.source = { :path => './Classes' }

  s.platform = :ios, '11.0'
  s.requires_arc = true

  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.{h}'

  s.dependency 'VEPlayerKit'
  s.dependency 'VEBaseKit'
end

Pod::Spec.new do |s|
  s.name = "VEBaseKit"
  s.version = "1.0.0"
  s.summary = "火山引擎点播基础组件"
  s.description = "火山引擎点播基础"
  s.homepage = "https://www.volcengine.com"
  s.license = 'MIT'
  s.author = { "wangzhiyong" => "wangzhiyong.7717@bytedance.com" }
  s.source = { :path => './Classes' }

  s.platform = :ios, '11.0'
  s.requires_arc = true
  
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.{h}'

  s.dependency 'Masonry'
  s.dependency 'Reachability'

  s.static_framework = true
end

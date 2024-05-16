Pod::Spec.new do |s|
  s.name = "VEVodMain"
  s.version = "1.0.0"
  s.summary = "火山引擎点播短视频入口和资源文件"
  s.description = "火山引擎点播短视频入口和资源文件"
  s.homepage = "https://www.volcengine.com"
  s.license = 'MIT'
  s.author = { "zhaoxiaoyu" => "zhaoxiaoyu.realxx@bytedance.com" }
  s.source = { :path => './Classes' }

  s.platform = :ios, '11.0'
  s.requires_arc = true

  s.source_files = 'Entry/*'
  s.public_header_files = 'Entry/*.{h}'

  s.resources = ['Resources/**/*.{xcassets,lproj}',
                 'Entry/*.{xib}'
  ]

  s.dependency 'TTSDKFramework/Player-SR'
  s.dependency 'VEPlayModule'

end

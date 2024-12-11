Pod::Spec.new do |s|
  s.name = "VESceneModule"
  s.version = "1.2.0"
  s.summary = "火山引擎点播全场景展示"
  s.description = "火山引擎点播全场景展示"
  s.homepage = "https://www.volcengine.com"
  s.license = 'MIT'
  s.author = { "zhaoxiaoyu" => "zhaoxiaoyu.realxx@bytedance.com" }
  s.source = { :path => './Classes' }

  s.platform = :ios, '11.0'
  s.requires_arc = true

  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.{h}'
  s.resources = 'Classes/**/*.{xib}'

  s.default_subspecs = 'Setting', 'LongVideo', 'FeedVideo', 'ShortVideo', 'ShortDrama', 'Ad', 'MediaModel'

  s.subspec 'Setting' do |subspec|
      subspec.public_header_files = [
        'Classes/Data/**/*.{h}',
        'Classes/Setting/**/*.{h}',
        'Classes/Util/**/*.{h}'
      ]
      subspec.source_files = [
        'Classes/Data/**/*',
        'Classes/Setting/**/*',
        'Classes/Util/**/*',
      ]
  end

  s.subspec 'LongVideo' do |subspec|
     subspec.public_header_files = [
        'Classes/LongVideo/**/*.{h}'
      ]
      subspec.source_files = [
        'Classes/LongVideo/**/*'
      ]
      subspec.resources = [
        'Classes/LongVideo/**/*.{xib}'
      ]
      subspec.dependency 'VESceneModule/Setting' 
  end

  s.subspec 'FeedVideo' do |subspec|
      subspec.public_header_files = [
        'Classes/FeedVideo/**/*.{h}'
      ]
      subspec.source_files = [
        'Classes/FeedVideo/**/*'
      ]
      subspec.resources = [
        'Classes/FeedVideo/**/*.{xib}'
      ]
      subspec.dependency 'VESceneModule/Setting' 
  end

  s.subspec 'ShortDrama' do |subspec|
      subspec.public_header_files = [
        'Classes/ShortDrama/**/*.{h}'
      ]
      subspec.source_files = [
        'Classes/ShortDrama/**/*'
      ]
      subspec.resources = [
        'Classes/ShortDrama/**/*.{xib}'
      ]
      subspec.dependency 'VESceneModule/Setting' 
  end

  s.subspec 'ShortVideo' do |subspec|
     subspec.public_header_files = [
        'Classes/ShortVideo/**/*.{h}'
      ]
      subspec.source_files = [
        'Classes/ShortVideo/**/*'
      ]
      subspec.dependency 'VESceneModule/Setting'  
  end
  
  s.subspec 'CustomPlayVideo' do |subspec|
     subspec.public_header_files = [
        'Classes/CustomPlayVideo/**/*.{h}'
      ]
      subspec.source_files = [
        'Classes/CustomPlayVideo/**/*'
      ]
      subspec.dependency 'VESceneModule/Setting'
      subspec.dependency 'VESceneModule/ShortVideo'
      subspec.dependency 'VESceneModule/FeedVideo'
  end

  s.subspec 'Ad' do |subspec|
     subspec.public_header_files = [
        'Classes/Ad/**/*.{h}'
      ]
      subspec.source_files = [
        'Classes/Ad/**/*'
      ]
      subspec.dependency 'VESceneModule/Setting'
  end

  s.subspec 'MediaModel' do |subspec|
    subspec.public_header_files = [
       'Classes/MediaModel/**/*.{h}'
     ]
     subspec.source_files = [
       'Classes/MediaModel/**/*'
     ]
     subspec.dependency 'VESceneModule/Ad'
     subspec.dependency 'VESceneModule/ShortDrama'
 end

  s.dependency 'Masonry'
  s.dependency 'SDWebImage'
  s.dependency 'MBProgressHUD', '~> 1.2.0'
  s.dependency 'Reachability'
  s.dependency 'JSONModel'
  
  s.dependency 'VEPlayerKit'
  s.dependency 'VEPlayerUIModule'
  s.dependency 'MJRefresh'
  s.dependency 'VEBaseKit'
  
end


#
# Be sure to run `pod lib lint PoporWatchMemory.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PoporWatchMemory'
  s.version          = '1.0'
  s.summary          = '基于 UIViewController 的内存泄露监测, 可以设定忽略的class, '

  s.homepage         = 'https://gitee.com/popor/PoporWatchMemory'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'popor' => '908891024@qq.com' }
  s.source           = { :git => 'https://gitee.com/popor/PoporWatchMemory.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files = 'PoporWatchMemory/Classes/**/*'
  
end

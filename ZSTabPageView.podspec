#
# Be sure to run `pod lib lint ZSTabPageView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ZSTabPageView'
  s.version          = '0.3.6'
  s.summary          = '标签和内容联动View'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
1. 顶部标签切换内容联动
2. ScrollView多级嵌套联动，可定义header和悬浮Tab
                       DESC

  s.homepage         = 'https://github.com/zhangsen093725/ZSTabPageView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  
  s.author           = { 'Josh' => '376019018@qq.com' }
  s.source           = { :git => 'https://github.com/zhangsen093725/ZSTabPageView.git', :tag => s.version.to_s }

  s.swift_version    = '5.0'
  s.ios.deployment_target = '8.0'

  s.source_files = 'ZSTabPageView/Classes/**/*'
  
  # s.resource_bundles = {
  #   'ZSTabPageView' => ['ZSTabPageView/Assets/*.png']
  # }

end

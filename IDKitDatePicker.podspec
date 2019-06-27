#
# Be sure to run `pod lib lint IDKitDatePicker.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'IDKitDatePicker'
  s.version          = '0.1.0'
  s.summary          = 'This is a scroll wheel date control that can be set in size.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
                        The control has basic and set properties, four initialization methods and one data refresh method, and four custom proxy methods.
                       DESC

  s.homepage         = 'https://github.com/zhoushuangjian511@163.com/IDKitDatePicker'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'zhoushuangjian511@163.com' => 'zhoushuangjian@algento.com' }
  s.source           = { :git => 'https://github.com/zhoushuangjian511@163.com/IDKitDatePicker.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'IDKitDatePicker/Classes/**/*'
  
  # s.resource_bundles = {
  #   'IDKitDatePicker' => ['IDKitDatePicker/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end

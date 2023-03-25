Pod::Spec.new do |s|
  s.name             = 'RangeSlider'
  s.version          = '1.0.0'
  s.summary          = 'RangeSlider is a SwiftUI view that allows the user to select a range of values by dragging two sliders.'
  s.homepage         = 'https://github.com/jackvdp/RangeSlider'
  s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
  s.author           = { 'jack Vanderpump' => 'jack@pumpymusic.co.uk' }
  s.source           = { :git => 'https://github.com/jackvdp/RangeSlider.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.swift_version = '5.0'
  s.source_files = 'Sources/RangeSlider/**/*'
end

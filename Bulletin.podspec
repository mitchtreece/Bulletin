Pod::Spec.new do |s|

  s.name             = 'Bulletin'
  s.version          = '1.0.0'
  s.summary          = 'A short description of Bulletin.'

  s.description      = <<-DESC
    TODO: Add long description of the pod here.
    DESC

  s.homepage         = 'https://github.com/mitchtreece/Bulletin'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'mitchtreece' => 'mitchtreece@me.com' }
  s.source           = { :git => 'https://github.com/mitchtreece/Bulletin.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  # s.frameworks = 'UIKit', 'MapKit'
  s.source_files = 'Bulletin/Classes/**/*'
  s.dependency 'SnapKit', '~> 3.0.0'

end

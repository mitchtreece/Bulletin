Pod::Spec.new do |s|

  s.name             = 'Bulletin'
  s.version          = '1.2.1'
  s.summary          = 'Customizable alert library for Swift.'

  s.description      = <<-DESC
    Bulletin is a customizable alert library that makes it incredibly
    easy to build highly-stylized alerts for your iOS app.
    DESC

  s.homepage         = 'https://github.com/mitchtreece/Bulletin'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mitch Treece' => 'mitchtreece@me.com' }
  s.source           = { :git => 'https://github.com/mitchtreece/Bulletin.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/MitchTreece'

  s.ios.deployment_target = '10.0'
  s.ios.public_header_files = 'Bulletin/Classes/**/*.h'
  s.source_files = 'Bulletin/Classes/**/*'

  s.dependency 'SnapKit', '~> 4.0.0'

end

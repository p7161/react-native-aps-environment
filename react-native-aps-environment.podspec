Pod::Spec.new do |s|
  s.name         = 'react-native-aps-environment'
  s.version      = '0.1.0'
  s.summary      = 'Expose iOS aps-environment to React Native'
  s.license      = { :type => 'MIT' }
  s.authors      = { 'you' => 'you@example.com' }
  s.homepage     = 'https://github.com/you/react-native-aps-environment'
  s.source       = { :git => 'https://github.com/you/react-native-aps-environment.git', :tag => s.version.to_s }

  s.platforms    = { :ios => '12.0' }
  s.source_files = 'ios/**/*.{m,mm,swift}'
  s.dependency   'React-Core'

  s.swift_version = '5.0'
end

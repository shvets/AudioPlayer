Pod::Spec.new do |s|
  s.name         = "AudioPlayer"
  s.version      = "1.0.12"
  s.summary      = "Audio Player"
  s.description  = "Audio Player description"

  s.homepage     = "https://github.com/shvets/AudioPlayer"
  s.authors = { "Alexander Shvets" => "alexander.shvets@gmail.com" }
  s.license      = "MIT"
  s.source = { :git => "https://github.com/shvets/AudioPlayer.git", :tag => s.version }

  s.ios.deployment_target = "10.0"
  s.tvos.deployment_target = "10.0"

  s.source_files = "Sources/**/*.swift"
  #s.resources = "Sources/Assets/**/*.xcassets"

  s.dependency 'Files', '~> 2.0.1'
  s.dependency 'ConfigFile', '~> 1.1.0'
  s.dependency 'PageLoader', '~> 1.0.0'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5' }
end

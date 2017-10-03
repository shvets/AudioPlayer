Pod::Spec.new do |s|
  s.name         = "AudioPlayer"
  s.version      = "1.0.8"
  s.summary      = "Audio Player"
  s.description  = "Audio Player description"

  s.homepage     = "https://github.com/shvets/AudioPlayer"
  s.authors = { "Alexander Shvets" => "alexander.shvets@gmail.com" }
  s.license      = "MIT"
  s.source = { :git => "https://github.com/shvets/AudioPlayer.git", :tag => s.version }

  s.ios.deployment_target = "10.0"
  #s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "9.0"
  #s.watchos.deployment_target = "2.0"

  s.source_files = "Sources/**/*.swift"

  #s.dependency 'SwiftyJSON', '~> 3.1.4'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4' }
end

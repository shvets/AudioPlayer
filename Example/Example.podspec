Pod::Spec.new do |s|
  s.name         = "Example"
  s.version      = "1.0.0"
  s.summary      = "Audio Player Example"
  s.description  = "Audio Player Example description"

  s.homepage     = "https://github.com/shvets/AudioPlayer"
  s.authors = { "Alexander Shvets" => "alexander.shvets@gmail.com" }
  s.license      = "MIT"
  s.source = { :git => "https://github.com/shvets/AudioPlayer.git", :tag => s.version }

  s.ios.deployment_target = "10.0"
  #s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "10.0"
  #s.watchos.deployment_target = "2.0"

  s.source_files = "Sources/**/*.swift"
  s.resources = "../Sources/Assets/**/*.xcassets"

  s.dependency 'WebAPI', '~> 1.0.11'

  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4' }
end

Pod::Spec.new do |s|
  s.name         = "AudioPlayer"
  s.version      = "1.0.0"
  s.summary      = "Audio Player"
  s.description  = Audio Player"

  s.homepage     = "https://github.com/shvets/AudioPlayer"
  s.license      = "MIT"

  s.authors = { "Alexander Shvets" => "alexander.shvets@gmail.com" }
  s.source = { :git => "https://github.com/shvets/AudioPlayer.git", :tag => s.version }

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.10"
  s.tvos.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"

  s.source_files = "Sources/*.swift"
end

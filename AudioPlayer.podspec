#swift_version = File.new('.swift-version').read

Pod::Spec.new do |s|
  s.name         = "AudioPlayer"
  s.version      = "1.0.14"
  s.summary      = "Audio Player"
  s.description  = "Audio Player description"

  s.homepage     = "https://github.com/shvets/AudioPlayer"
  s.authors = { "Alexander Shvets" => "alexander.shvets@gmail.com" }
  s.license      = "MIT"

  s.ios.deployment_target = "12.2"
  s.tvos.deployment_target = "12.2"

  s.source = { :git => "https://github.com/shvets/AudioPlayer.git", :tag => s.version }

  s.source_files = "Sources/**/*.swift"
  #s.exclude_files = "Classes/Exclude"
  # s.public_header_files = "Classes/**/*.h"
  #s.resources = "Sources/Assets/**/*.xcassets"

#  s.dependency 'Files', '~> 2.0.1'
#  s.dependency 'ConfigFile', '~> 1.1.0'
  s.dependency 'PageLoader', '~> 1.0.0'
  s.dependency 'SimpleHttpClient', '~> 1.0.3'

  #s.pod_target_xcconfig = { 'SWIFT_VERSION' => swift_version }
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }
  s.swift_versions = '5.0'
end

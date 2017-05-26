use_frameworks!

def project_dependencies
  pod 'SwiftyJSON', '~> 3.1.4'
end

target 'AudioPlayer_iOS' do
  platform :ios, '10.0'

  podspec :path => 'AudioPlayer.podspec'

  project_dependencies

  target 'AudioPlayer_iOSTests' do
    inherit! :search_paths
  end
end

target 'AudioPlayer_tvOS' do
  platform :tvos, '10.10'

  podspec :path => 'AudioPlayer.podspec'

  project_dependencies

  target 'AudioPlayer_tvOSTests' do
    inherit! :search_paths
  end
end

target 'AudioPlayer_macOS' do
  platform :osx, '10.10'

  podspec :path => 'AudioPlayer.podspec'

  project_dependencies

  target 'AudioPlayer_macOSTests' do
    inherit! :search_paths
  end
end

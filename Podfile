source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/shvets/Specs.git'

def pods
  #pod 'SimpleHttpClient', path: '../SimpleHttpClient'
  #pod 'PageLoader', path: '../PageLoader'
#  pod 'ConfigFile', path: '../ConfigFile'
end

target 'AudioPlayer_iOS' do
  platform :ios, '12.2'

  use_frameworks!

  pods

  podspec :path => 'AudioPlayer.podspec'

  target 'AudioPlayer_iOSTests' do
    inherit! :search_paths
  end
end

target 'AudioPlayer_tvOS' do
  platform :tvos, '12.2'

  use_frameworks!

  pods

  podspec :path => 'AudioPlayer.podspec'

  target 'AudioPlayer_tvOSTests' do
    inherit! :search_paths
  end
end

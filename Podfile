source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!
platform :ios, '10.0'

def shared_pods
  pod 'Alamofire', '~> 4.4'
  pod 'SwiftLint'
end

target 'INGAccounts' do
    shared_pods
end

target 'INGAccountsTests' do
    shared_pods
end

target 'INGAccountsToday' do
    shared_pods
end

target 'INGAccountWatchExtension' do
    platform :watchos, '3.0'
    shared_pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.1'
        end
    end
end

# Uncomment the next line to define a global platform for your project
 platform :ios, '13.0'

workspace 'msp-ios-sdk'


project 'MSPDemoApp/MSPDemoApp'



  
target 'MSPDemoApp' do
  project 'MSPDemoApp/MSPDemoApp'
  #pod 'GoogleAdapter',  :path => 'GoogleAdapter', :modular_headers => true
  #use_frameworks!
  pod 'MSPCore', '0.0.65', :modular_headers => true
  pod 'NovaAdapter', '0.0.65', :modular_headers => true
  pod 'GoogleAdapter', '0.0.66', :modular_headers => true
  pod 'FacebookAdapter', '0.0.68', :modular_headers => true
 
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      #config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      config.build_settings['OTHER_SWIFT_FLAGS'] = '-no-verify-emitted-module-interface'
    end
  end
end





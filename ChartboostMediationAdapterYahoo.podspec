Pod::Spec.new do |spec|
  spec.name        = 'ChartboostMediationAdapterYahoo'
  spec.version     = '4.1.4.0.0'
  spec.license     = { :type => 'MIT', :file => 'LICENSE.md' }
  spec.homepage    = 'https://github.com/ChartBoost/chartboost-mediation-ios-adapter-yahoo'
  spec.authors     = { 'Chartboost' => 'https://www.chartboost.com/' }
  spec.summary     = 'Chartboost Mediation iOS SDK Yahoo adapter.'
  spec.description = 'Yahoo Adapters for mediating through Chartboost Mediation. Supported ad formats: Banner, Interstitial, and Rewarded.'

  # Source
  spec.module_name  = 'ChartboostMediationAdapterYahoo'
  spec.source       = { :git => 'https://github.com/ChartBoost/chartboost-mediation-ios-adapter-yahoo.git', :tag => spec.version }
  spec.resource_bundles = { 'ChartboostMediationAdapterYahoo' => ['PrivacyInfo.xcprivacy'] }
  spec.source_files = 'Source/**/*.{swift}'

  # Minimum supported versions
  spec.swift_version         = '5.0'
  spec.ios.deployment_target = '11.0'

  # System frameworks used
  spec.ios.frameworks = ['Foundation', 'SafariServices', 'UIKit', 'WebKit']
  
  # This adapter is compatible with all Chartboost Mediation 4.X versions of the SDK.
  spec.dependency 'ChartboostMediationSDK', '~> 4.0'

  # Partner network SDK and version that this adapter is certified to work with.
  spec.dependency 'Yahoo-Mobile-SDK', '~> 1.4.0'
  
  # The partner network SDK is a static framework which requires the static_framework option.
  spec.static_framework = true
end

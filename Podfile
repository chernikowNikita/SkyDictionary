use_frameworks!
platform :ios, '12.0'
inhibit_all_warnings!

abstract_target 'SkyDictionaryAbstract' do
  # core RxSwift
  pod 'RxSwift', '4.4.1'

  # Community projects
  pod 'Action', '~> 3.9'
  pod 'RxSwiftExt/Core'
  
  # API
  pod 'Moya/RxSwift', '~> 13.0'

    target 'SkyDictionary' do
        platform :ios, '12.0'
          pod 'RxCocoa', '4.4.1'
  	  pod 'RxDataSources', '~> 3.1'
	  # Image Loading
  	  pod 'Kingfisher', '~> 5.0'
    end
    
    target 'SkyDictionaryTests' do
        platform :ios, '12.0'
        pod 'RxTest', '4.4.1'
        pod 'RxBlocking', '4.4.1'
    end
end

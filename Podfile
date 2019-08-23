platform :ios, "11.0"
inhibit_all_warnings!

def development_pods
  pod 'SwiftFormat/CLI', :configuration => 'Debug'
end

target '2048X AI' do
  use_frameworks!

  development_pods

  pod 'Then', '~> 2.5'

  pod 'Firebase/Core'
  pod 'Firebase/Analytics'
  pod 'Firebase/Performance'
  pod 'Crashlytics'
  # pod 'Firebase/AdMob'
  # pod 'Firebase/RemoteConfig'

  pod 'ChouTi', :path => './Submodules/ChouTi'
  pod 'ChouTiUI', :path => './Submodules/ChouTiUI'

  target '2048 SolverTests' do
    inherit! :search_paths
  end

end

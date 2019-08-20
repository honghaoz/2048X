platform :ios, "12.0"
use_frameworks!

def development_pods
  pod 'SwiftFormat/CLI', :configuration => 'Debug'
end

target '2048X AI' do

  development_pods

  pod 'Then', '~> 2.5'
  # Utility
  # pod 'Loggerithm', :configurations => ['Debug']
  pod 'ChouTi', '~> 0.6'
  pod 'ChouTiUI', '~> 0.6'

  # Analytics
  # pod 'Google/Analytics'

end

target '2048 SolverTests' do

end

# post_install_hooks
#post_install do |installer|
#    installer.pods_project.targets.each do |target|
#        if target.name == 'Loggerithm'
#            target.build_configurations.each do |config|
#                if config.name == 'Debug'
#                    config.build_settings['OTHER_SWIFT_FLAGS'] = '-D DEBUG'
#				else
#                    config.build_settings['OTHER_SWIFT_FLAGS'] = ''
#                end
#            end
#        end
#    end
#end

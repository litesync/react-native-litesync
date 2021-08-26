require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name     = "react-native-octodb"
  s.version  = package['version']
  s.summary  = package['description']
  s.homepage = "https://github.com/octodb/react-native-octodb"
  s.license  = package['license']
  s.author   = package['author']
  s.source   = { :git => "https://github.com/octodb/react-native-octodb.git", :tag => "#{s.version}" }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'

  s.preserve_paths = 'README.md', 'LICENSE', 'package.json', 'sqlite.js'
  s.source_files   = "platforms/ios/*.{h,m}"

  s.libraries = 'octodb', 'binn', 'uv', 'secp256k1-vrf'
  s.xcconfig = {
    'LIBRARY_SEARCH_PATHS' => "$(inherited) $(SRCROOT)/../node_modules/react-native-octodb/platforms/ios/lib"
  }

  s.dependency 'React'
end

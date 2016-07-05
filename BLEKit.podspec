Pod::Spec.new do |s|
  s.name     = 'BLEKit'
  s.version  = '1.0.0'
  s.summary  = 'BLEKit is an Objective-C abstraction layer on the Bluetooth Low Energy CoreBluetooth framework to use with BLEKit peripherals.'
  s.description = <<-DESC
                    BLEKit is an Objective-C abstraction layer on the Bluetooth Low Energy CoreBluetooth
                    framework to use with BLEKit peripherals.
                    With BLEKit you can
                    * Discover BLEKit devices around your BLEKit peripheral
                    * Update the firmware on your BLEKit peripheral
                    * Connect and communicate with different ports on your BLEKit peripheral
                    DESC
  s.homepage = 'http://ble-kit.org'
  s.license  = 'MIT'
  s.author   = { 'Igor Sales' => 'self@igorsales.ca' }
  s.social_media_url = 'https://twitter.com/igorsales'
 
  s.ios.deployment_target = '8.0'
  # s.osx.deployment_target = '10.8' # TODO
  # s.tvos.deployment_target = '9.0' # TODO
  s.source   = { :git => 'https://github.com/igorsales/blekit.git', :tag => 'v1.0.0' }
  s.source_files = 'src/**/*.{h,m}'
  s.resources = 'Resources/BLK*.plist', 'Resources/Base.lproj/BLK*.{xib,storyboard}'
  s.public_header_files = 'src/**/*.h'
  s.requires_arc = true
end

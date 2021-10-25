Pod::Spec.new do |s|
  
  s.name         = "ReadWriteLock"
  s.version      = "1.0.3"
  s.summary      = "A Swifty Read-Write lock"
  s.description  = <<-DESC
                   A lightweight framework of a safe an easy implementation of a read-write lock for iOS, macOS, tvOS, and watchOS.
                   DESC
  
  s.homepage     = "https://github.com/SomeRandomiOSDev/ReadWriteLock"
  s.license      = "MIT"
  s.author       = { "Joe Newton" => "somerandomiosdev@gmail.com" }
  s.source       = { :git => "https://github.com/SomeRandomiOSDev/ReadWriteLock.git", :tag => s.version.to_s }

  s.ios.deployment_target     = '9.0'
  s.macos.deployment_target   = '10.10'
  s.tvos.deployment_target    = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files      = 'Sources/ReadWriteLock/*.swift'
  s.swift_versions    = ['5.0']
  s.cocoapods_version = '>= 1.7.3'

  s.test_spec 'Tests' do |ts|
    ts.ios.deployment_target     = '9.0'
    ts.macos.deployment_target   = '10.10'
    ts.tvos.deployment_target    = '9.0'
    ts.watchos.deployment_target = '2.0'

    ts.source_files = 'Tests/ReadWriteLockTests/*.swift'
  end
  
end

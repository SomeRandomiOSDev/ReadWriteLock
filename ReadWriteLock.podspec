Pod::Spec.new do |s|
  
  s.name         = "ReadWriteLock"
  s.version      = "1.0.0"
  s.summary      = "A Swifty Read-Write lock"
  s.description  = <<-DESC
                   A lightweight framework of a safe an easy implementation of a read-write lock for iOS, macOS, tvOS, and watchOS.
                   DESC
  
  s.homepage     = "https://github.com/SomeRandomiOSDev/ReadWriteLock"
  s.license      = "MIT"
  s.author       = { "Joseph Newton" => "somerandomiosdev@gmail.com" }

  s.ios.deployment_target     = '8.0'
  s.macos.deployment_target   = '10.10'
  s.tvos.deployment_target    = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source        = { :git => "https://github.com/SomeRandomiOSDev/ReadWriteLock.git", :tag => s.version.to_s }
  s.source_files  = 'ReadWriteLock/**/*.swift'
  s.swift_version = '5.0'
  s.requires_arc  = true
  
end

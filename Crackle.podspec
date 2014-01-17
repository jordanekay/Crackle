Pod::Spec.new do |s|
  s.name         = 'Crackle'
  s.version      = '1.0.0'
  s.summary      = 'An Objective-C wrapper around the 37signals Campfire API.'
  s.homepage     = 'https://www.github.com/jordanekay/Crackle'
  s.platform     = :ios, '6.0'
  s.requires_arc = true
  s.source_files = '{Campfire,Extensions}/*.{h,m}'
  s.authors = {
    'Jordan Kay' => 'jordanekay@mac.com'
  }
  s.source = {
    :git => 'https://github.com/jordanekay/Crackle.git',
    :tag => '1.0.0'
  }
  s.license = {
    :type => 'MIT'
  }
  s.dependency 'AFNetworking'
  s.dependency 'Lockbox'
  s.dependency 'Mantle'
  s.dependency 'XMLDictionary'
end

#
#  Be sure to run `pod spec lint HexGrid.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "HexGrid"
  s.version      = "2.0.3"
  s.platform     = :ios, "9.0"
  s.summary      = "HexGridSwift."
  s.homepage     = "https://github.com/gtforge/HexGridSwift"
  s.license      = "BSD"
  s.author       = { "Gil Polak" => "gilp@gett.com" }
  s.source       = { :git => "https://github.com/gtforge/HexGridSwift.git" }
  s.source_files  = "HexGrid/*"
  s.dependency 'Morton'


end

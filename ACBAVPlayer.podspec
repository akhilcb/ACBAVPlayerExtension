Pod::Spec.new do |s|
  s.name         = "ACBAVPlayer"
  s.version      = "2.0"
  s.summary      = "An extension on AVPlayer which converts it to have all useful features of AVAudioPlayer but with streaming support."
  s.description  = <<-DESC
  An extension on AVPlayer which converts it to have all useful features of AVAudioPlayer but with streaming support. Also added additional methods to support Audio visualization from AVPlayer streaming. This extension adds some missing features to AVPlayer.
                   DESC
  s.homepage     = "https://github.com/akhilcb/ACBAVPlayerExtension"
  s.license      = "MIT"
  s.author    	 = "Akhil"
  s.platform     = :ios
  s.source       = { :git => "https://github.com/akhilcb/ACBAVPlayerExtension.git", :tag => "2.0" }
  s.source_files  = "ACBAVPlayerExtension", "ACBAVPlayerExtension/Classes/AudioProcessing/AVPlayer+ACBHelper.{h,m}"
  s.exclude_files = "ACBAVPlayerExtension/main.m"
  s.public_header_files = "ACBAVPlayer/ACBPlayer.h"
end

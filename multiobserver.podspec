# Copyright (c) Akos Polster. All rights reserved.

Pod::Spec.new do |s|
  s.name = "multiobserver"
  s.version = "0.1.0"
  s.summary = "Combine multiple observations to trigger a single action"

  s.description = <<-DESC
This Objective C frameworks allows combining multiple key-value observations,
and calling a single notification callback with the result of the combined 
observations.
                   DESC

  s.homepage = "https://github.com/pipacs/multiobserver"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  s.license = "MIT"
  s.author = { "Akos Polster" => "akos@pipacs.com" }
  s.platform = :ios
  s.source = { :git => "https://github.com/pipacs/multiobserver.git", :tag => "0.1.0" }
  s.source_files = "PIMultiObserver/PIMultiObserver", "PIMultiObserver/PIMultiObserver/**/*.{h,m}"
  s.exclude_files = "PIMultiObserver/PIMultiObserver/Exclude"
end

# Copyright (c) Akos Polster. All rights reserved.

Pod::Spec.new do |s|
  s.name = "PIMultiObserver"
  s.version = "0.1.0"
  s.summary = "Controller combine multiple observations to trigger a single action"
  s.description = <<-DESC
This Objective C frameworks allows combining multiple key-value observations,
and calling a single notification callback with the result of the combined 
observations.
                   DESC
  s.homepage = "https://github.com/pipacs/multiobserver"
  s.license = "MIT"
  s.author = { "Akos Polster" => "akos@pipacs.com" }
  s.platform = :ios, '8.0'
  s.source = { :git => "https://github.com/pipacs/multiobserver.git", :tag => s.version.to_s }
  s.source_files = "PIMultiObserver/*.{h,m}"
end

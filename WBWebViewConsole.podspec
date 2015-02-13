Pod::Spec.new do |s|
  s.name         = "WBWebViewConsole"
  s.platform     = :ios
  s.version      = "1.0.0"
  s.summary      = "In app debug console for your iOS app's WebView."
  s.homepage     = "https://github.com/Naituw/WBWebViewConsole"
  s.license      = "MIT"
  s.authors      = {"Naituw" => "naituw@gmail.com"}
  s.source       = {:git => "https://github.com/Naituw/WBWebViewConsole.git", :tag => '1.0.0'}
  s.source_files = 'WBWebViewConsole/**/*.{h,m}'
  s.requires_arc = true
  s.resources = ["WBWebViewConsole/Resources/*",
                 "WBWebViewConsole/Supports/WBWebView/JSBridge/Resources/*"]
end
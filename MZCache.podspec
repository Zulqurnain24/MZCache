Pod::Spec.new do |spec|

  spec.name         = "MZCache"
  spec.version      = "1.0.0"
  spec.summary      = "MZCache is a framework for custom caching"

  spec.description  = "MZCache is a framework for defining custom cache which can be used for caching JSON and XML object downloaded from the server. It can work perfectly with multi-threading"

  spec.homepage     = "https://github.com/Zulqurnain24/MZCache"
  spec.license      = "MIT"
  spec.author             = { "Mohammad Zulqurnain" => "mohammad.zulqurnain@gmail.com" }

  spec.social_media_url   = "https://www.linkedin.com/in/mohammad-zulqurnain-2448414b/"

  spec.platform     = :ios, "13.0"

  spec.source       = { :git => "https://github.com/Zulqurnain24/MZCache.git", :tag => "1.0.0" }

  spec.source_files  = "MZCache"

end

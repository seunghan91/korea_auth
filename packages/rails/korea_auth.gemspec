# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "korea_auth"
  spec.version       = "0.1.0"
  spec.authors       = ["Korea Auth Contributors"]
  spec.email         = ["your-email@example.com"]

  spec.summary       = "Korean social login token verification for Rails"
  spec.description   = "Verify Kakao, Naver, Google, and Apple login tokens in your Rails backend"
  spec.homepage      = "https://github.com/your-org/korea_auth"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.files = Dir["lib/**/*", "README.md", "LICENSE"]
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", "~> 0.21"
  spec.add_dependency "jwt", "~> 2.7"

  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "webmock", "~> 3.18"
end

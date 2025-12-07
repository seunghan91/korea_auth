# frozen_string_literal: true

require_relative "korea_auth/version"
require_relative "korea_auth/providers/base"
require_relative "korea_auth/providers/kakao"
require_relative "korea_auth/providers/naver"
require_relative "korea_auth/providers/google"
require_relative "korea_auth/providers/apple"
require_relative "korea_auth/result"

module KoreaAuth
  class Error < StandardError; end

  PROVIDERS = {
    kakao: Providers::Kakao,
    naver: Providers::Naver,
    google: Providers::Google,
    apple: Providers::Apple
  }.freeze

  class << self
    def verify(provider, token)
      provider_sym = provider.to_sym
      raise Error, "Unknown provider: #{provider}" unless PROVIDERS.key?(provider_sym)

      PROVIDERS[provider_sym].new.verify(token)
    end
  end
end

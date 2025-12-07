# frozen_string_literal: true

require "httparty"
require "jwt"

module KoreaAuth
  module Providers
    class Google < Base
      TOKEN_INFO_URL = "https://oauth2.googleapis.com/tokeninfo"

      def verify(token)
        # For ID tokens, we can verify with Google's tokeninfo endpoint
        response = HTTParty.get("#{TOKEN_INFO_URL}?id_token=#{token}")
        
        unless response.success?
          return Result.failure("Invalid token")
        end

        data = response.parsed_response

        Result.success(
          uid: data["sub"],
          provider: "google",
          name: data["name"],
          email: data["email"],
          photo_url: data["picture"],
          raw_data: data
        )
      rescue StandardError => e
        Result.failure(e.message)
      end
    end
  end
end

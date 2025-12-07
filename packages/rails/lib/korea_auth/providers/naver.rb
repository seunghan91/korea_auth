# frozen_string_literal: true

require "httparty"

module KoreaAuth
  module Providers
    class Naver < Base
      USER_INFO_URL = "https://openapi.naver.com/v1/nid/me"

      def verify(token)
        response = HTTParty.get(USER_INFO_URL, headers: auth_header(token))
        
        unless response.success? && response["resultcode"] == "00"
          return Result.failure("Invalid token or API error: #{response['message']}")
        end

        data = response["response"]

        Result.success(
          uid: data["id"],
          provider: "naver",
          name: data["name"] || data["nickname"],
          email: data["email"],
          photo_url: data["profile_image"],
          raw_data: data
        )
      rescue StandardError => e
        Result.failure(e.message)
      end

      private

      def auth_header(token)
        { "Authorization" => "Bearer #{token}" }
      end
    end
  end
end

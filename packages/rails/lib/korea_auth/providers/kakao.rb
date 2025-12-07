# frozen_string_literal: true

require "httparty"

module KoreaAuth
  module Providers
    class Kakao < Base
      TOKEN_INFO_URL = "https://kapi.kakao.com/v1/user/access_token_info"
      USER_INFO_URL = "https://kapi.kakao.com/v2/user/me"

      def verify(token)
        # First, verify the token is valid
        token_response = HTTParty.get(TOKEN_INFO_URL, headers: auth_header(token))
        
        unless token_response.success?
          return Result.failure("Invalid token: #{token_response['msg']}")
        end

        # Then get user info
        user_response = HTTParty.get(USER_INFO_URL, headers: auth_header(token))
        
        unless user_response.success?
          return Result.failure("Failed to get user info")
        end

        data = user_response.parsed_response
        account = data["kakao_account"] || {}
        profile = account["profile"] || {}

        Result.success(
          uid: data["id"].to_s,
          provider: "kakao",
          name: profile["nickname"],
          email: account["email"],
          photo_url: profile["profile_image_url"],
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

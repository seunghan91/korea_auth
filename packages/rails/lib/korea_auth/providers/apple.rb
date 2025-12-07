# frozen_string_literal: true

require "jwt"
require "httparty"

module KoreaAuth
  module Providers
    class Apple < Base
      APPLE_KEYS_URL = "https://appleid.apple.com/auth/keys"

      def verify(token)
        # Decode and verify Apple's identity token (JWT)
        # Fetch Apple's public keys
        keys_response = HTTParty.get(APPLE_KEYS_URL)
        
        unless keys_response.success?
          return Result.failure("Failed to fetch Apple public keys")
        end

        jwks = keys_response.parsed_response

        # Decode the JWT header to find the right key
        header = JWT.decode(token, nil, false).last
        key_data = jwks["keys"].find { |k| k["kid"] == header["kid"] }

        unless key_data
          return Result.failure("No matching key found")
        end

        # Build the public key
        jwk = JWT::JWK.new(key_data)
        
        # Decode and verify the token
        decoded = JWT.decode(token, jwk.public_key, true, { algorithm: "RS256" })
        payload = decoded.first

        Result.success(
          uid: payload["sub"],
          provider: "apple",
          name: nil, # Apple doesn't always provide name in the token
          email: payload["email"],
          photo_url: nil,
          raw_data: payload
        )
      rescue JWT::DecodeError => e
        Result.failure("JWT decode error: #{e.message}")
      rescue StandardError => e
        Result.failure(e.message)
      end
    end
  end
end

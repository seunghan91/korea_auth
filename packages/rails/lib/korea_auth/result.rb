# frozen_string_literal: true

module KoreaAuth
  class Result
    attr_reader :uid, :provider, :name, :email, :photo_url, :raw_data, :error

    def initialize(success:, uid: nil, provider: nil, name: nil, email: nil, photo_url: nil, raw_data: nil, error: nil)
      @success = success
      @uid = uid
      @provider = provider
      @name = name
      @email = email
      @photo_url = photo_url
      @raw_data = raw_data
      @error = error
    end

    def success?
      @success
    end

    def failure?
      !@success
    end

    def self.success(uid:, provider:, name: nil, email: nil, photo_url: nil, raw_data: nil)
      new(success: true, uid: uid, provider: provider, name: name, email: email, photo_url: photo_url, raw_data: raw_data)
    end

    def self.failure(error)
      new(success: false, error: error)
    end
  end
end

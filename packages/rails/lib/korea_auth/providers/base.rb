# frozen_string_literal: true

module KoreaAuth
  module Providers
    class Base
      def verify(token)
        raise NotImplementedError, "Subclasses must implement #verify"
      end

      protected

      def provider_name
        self.class.name.split("::").last.downcase
      end
    end
  end
end

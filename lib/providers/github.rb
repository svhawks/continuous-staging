module Providers
  class Github
    attr_reader :payload

    def initialize(payload)
      @payload = payload
    end

    def name
      payload['repository']['name']
    end

    def branch
      payload['ref'].gsub('refs/heads/', '').to_s
    end
  end
end

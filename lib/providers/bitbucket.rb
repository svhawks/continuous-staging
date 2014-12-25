module Providers
  class Bitbucket
    attr_reader :payload

    def initialize(payload)
      @payload = payload
    end

    def name
      payload['repository']['name']
    end

    def branch
      p payload
      payload['commits'].first['branch'].to_s.gsub('refs/heads/', '').to_s
    end
  end
end

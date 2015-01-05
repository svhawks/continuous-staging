class Application < OpenStruct
end

class NullApplication
  include Log

  def initialize
    logger.info 'Application sent in payload not found'
  end

  def git_provider
    'github'
  end

  def path
    '/dev/null'
  end
end

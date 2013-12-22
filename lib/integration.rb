class Integration
  attr_accessor :path, :type

  def initialize
    @type = :new_deploy
  end

  def message
    send("message_for_#{type}")
  end

  def from
    'MLLDeployBot'
  end

  def message_for_new_deploy
    %{<a href="#{url}">#{url}</a> has been deployed!}
  end

  def message_for_update
    %{<a href="#{url}">#{url}</a> has been updated!}
  end

  def self.update(path, type = :new_deploy)
    integration = new
    integration.path = path
    integration.type = type
    integration.update
  end

  private
  def url
    sub_domain = path.split('/').last
    "http://#{sub_domain}.staging.movielala.com"
  end
end

class Integration
  attr_accessor :path, :type

  def initialize
    @type = :new_deploy
  end

  def message(format = :html)
    send("message_for_#{type}", format)
  end

  def api_token
    @api_token ||= Settings.new.api_token
  end

  def from
    'MLLDeployBot'
  end

  def message_for_new_deploy(format = :html)
    if format == :html
      %{<a href="#{url}">#{url}</a> has been deployed!}
    else
      %{#{url} has been deployed!}
    end
  end

  def message_for_update(format = :html)
    if format == :html
      %{<a href="#{url}">#{url}</a> has been updated!}
    else
      %{#{url} has been updated!}
    end
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

module AppHelper
  def current_app
    Settings.find(name) || NullApplication.new
  end

  def current_app_exists?
    !current_app.is_a?(NullApplication)
  end
end

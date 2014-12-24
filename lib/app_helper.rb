module AppHelper
  def current_app
    Settings.find(name)
  end

  def current_app_exists?
    !!current_app
  end
end

require 'yaml'
require 'ostruct'
require_relative 'application'

class Settings
  attr_reader :applications

  def initialize
    load_settings
  end

  def self.apps
    @apps ||= new.applications
  end

  def self.find(name)
    apps.find {|app| app.name == name }
  end

  def configuration
    YAML.load_file(file)
  end

  private

  def load_settings
    @applications = configuration['applications'].map do |app|
      Application.new(app)
    end
  end

  def file
    File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'settings.yml'))
  end
end


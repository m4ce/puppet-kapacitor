begin
  require 'puppet_x/kapacitor/api'
rescue LoadError => detail
  module_base = Pathname.new(__FILE__).dirname
  require module_base + '../../../puppet_x/kapacitor/api'
end

Puppet::Type.type(:kapacitor_template).provide(:kapacitor_api) do
  desc "Manage Kapacitor templates"

  confine :feature => :kapacitor_api

  # Mix in the api as instance methods
  include PuppetX::Kapacitor::API

  # Mix in the api as class methods
  extend PuppetX::Kapacitor::API

  def self.instances
    instances = []
    api.templates.each do |template|
      instances << new(
        :name => template['id'],
        :type => template['type'].to_sym,
        :script => template['script'],
        :ensure => :present
      )
    end
    instances
  end

  def self.prefetch(resources)
    templates = instances
    resources.each do |name, resource|
      if provider = templates.find { |template| template.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    begin
      api.define_template(id: resource[:name], type: resource[:type].to_s, script: resource[:script])
    rescue
      fail "Could not create template #{self.name}: #{$!}"
    end

    @property_hash[:ensure] = resource[:ensure]
  end

  def destroy
    api.delete_template(id: resource[:name])
    @property_hash.clear
  end

  # Using mk_resource_methods relieves us from having to explicitly write the getters for all properties
  mk_resource_methods

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def type=(value)
    @property_flush[:type] = value.to_s
  end

  def script=(value)
    @property_flush[:script] = value
  end

  def flush
    unless @property_flush.empty?
      api.update_template(id: resource[:name], **@property_flush)
    end
  end
end

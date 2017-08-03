require 'kapacitor/client' if Puppet.features.kapacitor_api?

Puppet::Type.type(:kapacitor_template).provide(:kapacitor_api) do
  desc "Manage Kapacitor templates"

  confine :feature => :kapacitor_api

  def self.instances
    instances = []
    Kapacitor::Client.new.templates.each do |template|
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
      Kapacitor::Client.new.define_template(resource[:name], {'type' => resource[:type].to_s, 'script' => resource[:script]})
    rescue
      raise Puppet::Error, "Could not create template #{self.name}: #{$!}"
    end

    @property_hash[:ensure] = resource[:ensure]
  end

  def destroy
    Kapacitor::Client.new.delete_template(resource[:name])
    @property_hash.clear
  end

  # Using mk_resource_methods relieves us from having to explicitly write the getters for all properties
  mk_resource_methods

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def type=(value)
    @property_flush['type'] = value.to_s
  end

  def script=(value)
    @property_flush['script'] = value
  end

  def flush
    unless @property_flush.empty?
      Kapacitor::Client.new.update_template(resource[:name], @property_flush)
    end
  end
end

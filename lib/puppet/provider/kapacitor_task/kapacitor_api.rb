begin
  require 'puppet_x/kapacitor/api'
rescue LoadError => detail
  module_base = Pathname.new(__FILE__).dirname
  require module_base + '../../../puppet_x/kapacitor/api'
end

Puppet::Type.type(:kapacitor_task).provide(:api) do
  desc "Manage Kapacitor tasks"

  confine :feature => :api

  # Mix in the api as instance methods
  include PuppetX::Kapacitor::API

  # Mix in the api as class methods
  extend PuppetX::Kapacitor::API

  def self.instances
    instances = []
    api.tasks.each do |task|
      instances << new(
        :name => task['id'],
        :type => task['type'].to_sym,
        :script => task['script'],
        :dbrps => task['dbrps'],
        :vars => task['vars'],
        :status => task['status'],
        :ensure => :present
      )
    end
    instances
  end

  def self.prefetch(resources)
    tasks = instances
    resources.each do |name, resource|
      if provider = tasks.find { |task| task.name == name }
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    task = {}

    task['type'] = resource[:type].to_s if resource[:type]
    task['script'] = resource[:script] if resource[:script]
    task['template_id'] = resource[:template_id] if resource[:template_id]
    task['dbrps'] = resource[:dbrps] if resource[:dbrps]
    task['status'] = resource[:enable] ? 'enabled' : 'disabled'
    task['vars'] = resource[:vars] if resource[:vars]

    begin
      api.define_task(id: resource[:name], **task)
    rescue
      fail "Could not create task #{self.name}: #{$!}"
    end

    @property_hash[:ensure] = resource[:ensure]
  end

  def destroy
    api.delete_task(id: resource[:name])
    @property_hash.clear
  end

  def enabled?
    @property_hash[:status] == 'enabled' ? :true : :false
  end

  # Using mk_resource_methods relieves us from having to explicitly write the getters for all properties
  mk_resource_methods

  def enable
    api.update_task(id: resource[:name], status: 'enabled'})
  end

  def disable
    api.update_task(id: resource[:name], status: 'disabled'})
  end

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

  def dbrps=(value)
    @property_flush['dbrps'] = value
  end

  def vars=(value)
    @property_flush['vars'] = value
  end

  def flush
    unless @property_flush.empty?
      api.update_task(id: resource[:name], **@property_flush)
    end
  end
end

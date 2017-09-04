begin
  require 'puppet_x/kapacitor/api'
rescue LoadError => detail
  module_base = Pathname.new(__FILE__).dirname
  require module_base + '../../../puppet_x/kapacitor/api'
end

Puppet::Type.type(:kapacitor_topic_handler).provide(:kapacitor_api) do
  desc "Manage Kapacitor topic handlers"

  confine :feature => :kapacitor_api

  # Mix in the api as instance methods
  include PuppetX::Kapacitor::API

  # Mix in the api as class methods
  extend PuppetX::Kapacitor::API

  def self.instances
    instances = []
    api.topics.each do |topic|
      api.topic_handlers(topic: topic).each do |handler|
        instances << new(
          :name => "#{topic}:#{handler['id']}",
          :handler => handler['id'],
          :topic => topic,
          :actions => handler['actions'],
          :ensure => :present
        )
      end
    end
    instances
  end

  def self.prefetch(resources)
    items = instances
    resources.each do |name, resource|
      if provider = items.find { |item| item.handler == resource[:handler] && item.topic == resource[:topic]}
        resources[name].provider = provider
      end
    end
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    begin
      api.define_topic_handler(id: resource[:handler], topic: resource[:topic], actions: resource[:actions]})
    rescue
      fail "Could not create topic handler #{self.name}: #{$!}"
    end

    @property_hash[:ensure] = resource[:ensure]
  end

  def destroy
    api.delete_topic_handler(id: resource[:handler], topic: resource[:topic])
    @property_hash.clear
  end

  # Using mk_resource_methods relieves us from having to explicitly write the getters for all properties
  mk_resource_methods

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def actions=(value)
    @property_flush['actions'] = value
  end

  def flush
    unless @property_flush.empty?
      api.update_topic_handler(id: resource[:handler], topic: resource[:topic], **@property_flush)
    end
  end
end

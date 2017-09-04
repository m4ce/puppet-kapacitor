Puppet::Type.newtype(:kapacitor_topic_handler) do
  @doc = 'Manage Kapacitor topic handlers'

  ensurable do
    defaultvalues
    defaultto(:present)
  end

  newparam(:name, :namevar => true) do
    desc 'Composite namevar in the form of \'<topic_name>:<handler_name>\''
  end

  newparam(:handler, :namevar => true) do
    desc 'Handler name'
  end

  newparam(:topic, :namevar => true) do
    desc 'Topic name'
  end

  newproperty(:actions, :array_matching => :all) do
    desc 'List of handler actions in the form of  [{"kind" => "ACTION_KIND", "options" => {}}]'

    validate do |value|
      fail 'Handler action must be a hash in the form of {"kind" => "ACTION_KIND", "options" => {}}' unless value.is_a?(Hash) and value.key?('kind')
    end
  end

  validate do
    if self[:ensure] != "absent"
      unless self[:actions]
        fail "Handler actions required for Kapacitor topic #{self[:topic]} handler #{self[:name]}"
      end
    end
  end

  def self.title_patterns
    [
      [ /(^([^:]+)$)/,
        [ [:name], [:handler] ]
      ],
      [ /(^([^:]+):([^:]+)$)/,
        [ [:name], [:topic], [:handler] ]
      ]
    ]
  end

  autorequire(:service) do
    ["kapacitor"]
  end
end

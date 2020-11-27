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

  newproperty(:kind) do
    desc 'The kind of handler'
  end

  newproperty(:match) do
    desc 'A lambda expression to filter matching alerts. By default, all alerts match'
  end

  newproperty(:options) do
    desc 'Configurable options determined by the handler kind'
  end

  validate do
    if self[:ensure] != "absent"
      unless self[:kind]
        fail "Handler kind required for Kapacitor topic #{self[:topic]} handler #{self[:name]}"
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

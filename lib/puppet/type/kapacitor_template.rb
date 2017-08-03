Puppet::Type.newtype(:kapacitor_template) do
  @doc = 'Manage Kapacitor templates'

  ensurable do
    defaultvalues
    defaultto(:present)
  end

  newparam(:name, :namevar => true) do
    desc 'Template name'
  end

  newproperty(:type) do
    desc 'Template type'
    newvalues(:stream, :batch)
  end

  newproperty(:script) do
    desc 'The content of the script'

    def is_to_s(value)
      if value
        value.inspect
      else
        super
      end
    end

    def should_to_s(newvalue = @should)
      if newvalue
        newvalue.inspect
      else
        super
      end
    end
  end

  validate do
    if self[:ensure] != "absent"
      raise ArgumentError, "Kapacitor type required for template #{self[:name]}" unless self[:type]
      raise ArgumentError, "Kapacitor script required for template #{self[:name]}" unless self[:script]
    end
  end

  autorequire(:service) do
    ["kapacitor"]
  end
end

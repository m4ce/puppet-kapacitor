Puppet::Type.newtype(:kapacitor_task) do
  @doc = 'Manage Kapacitor tasks'

  ensurable do
    defaultvalues
    defaultto(:present)
  end

  newparam(:name, :namevar => true) do
    desc 'Task name'
  end

  newproperty(:type) do
    desc 'Task type'
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

  newparam(:template_id) do
    desc 'An optional ID of a template to use instead of specifying a TICKscript and type directly'
  end

  newproperty(:dbrps, :array_matching => :all) do
    desc 'List of database retention policy pairs the task is allowed to access in the form of  [{"db" => "DATABASE_NAME", "rp" => "RP_NAME"}]'

    validate do |value|
      unless value.is_a?(Hash) && value.key?('db') && value.key?('rp')
        fail 'Task database/retention policy pairs needs to be a Hash in the form of {"db" => "DATABASE_NAME", "rp" => "RP_NAME"}'
      end
    end
  end

  newproperty(:vars) do
    desc 'A set of vars for overwriting any defined vars in the TICKscript'

    validate do |value|
      fail 'Task vars must be a Hash in the form of {"field_name" => {"value" => VALUE, "type" => "TYPE", "description" => "STRING"}}' unless value.is_a?(Hash)

      value.each do |field_name, field|
        fail "Missing 'value' parameter for field '#{field_name}' in Kapacitor task #{self[:name]}" unless field.key?('value')
        fail "Missing 'type' parameter for field '#{field_name} in Kapacitor task #{self[:name]}'" unless field.key?('type')
        fail "Not a valid type '#{field['type']} for field '#{field_name}' in Kapacitor task #{self[:name]}" unless ['bool', 'int', 'float', 'duration', 'string', 'regex', 'lambda', 'star', 'list'].include?(field['type'])
      end
    end
  end

  validate do
    if self[:ensure] != "absent"
      if (self[:template_id].nil? && self[:type].nil? && self[:script].nil?) || (self[:template_id] && (self[:type] || self[:script]))
        fail "Kapacitor Template ID or type/script required for task #{self[:name]}"
      elsif self[:template_id].nil? && (self[:type].nil? || self[:script].nil?)
        fail "Kapacitor type/script required for task #{self[:name]} when not using a Template ID"
      end

      fail 'Kapacitor task requires at least one database and retention policy' if self[:dbrps].nil? || self[:dbrps].empty?
    end
  end

  newproperty(:enable) do
    desc 'Whether the task should be enabled or not'

    newvalue(:true) do
      provider.enable
    end

    newvalue(:false) do
      provider.disable
    end

    def retrieve
      provider.enabled?
    end
  end

  autorequire(:service) do
    ["kapacitor"]
  end

  autorequire(:kapacitor_template) do
    [self[:template_id]]
  end
end

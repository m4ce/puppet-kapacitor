#
# kapacitor_task.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

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
  end

  newparam(:template_id) do
    desc 'An optional ID of a template to use instead of specifying a TICKscript and type directly'
  end

  newproperty(:dbrps, :array_matching => :all) do
    desc 'List of database retention policy pairs the task is allowed to access in the form of  [{"db" => "DATABASE_NAME", "rp" => "RP_NAME"}]'

    validate do |value|
      if (!value.is_a?(Hash)) or (!value.has_key?('db') or !value.has_key?('rp'))
        raise ArgumentError, 'Task database/retention policy pairs needs to be a Hash in the form of {"db" => "DATABASE_NAME", "rp" => "RP_NAME"}'
      end
    end
  end

  newproperty(:vars) do
    desc 'A set of vars for overwriting any defined vars in the TICKscript'

    validate do |value|
      unless value.is_a?(Hash)
        raise ArgumentError, 'Task vars must be a Hash in the form of {"field_name" => {"value" => "VALUE", "type" => "TYPE"}}'
      end

      value.each do |field_name, field|
        raise ArgumentError, "Missing 'value' parameter for field '#{field_name}'" unless field.has_key?('value')
        raise ArgumentError, "Missing 'type' parameter for field '#{field_name}'" unless field.has_key?('type')
      end
    end
  end

  validate do
    if self[:ensure] != "absent"
      if (self[:template_id].nil? and self[:type].nil? and self[:script].nil?) or (self[:template_id] and (self[:type] or self[:script]))
        raise ArgumentError, "Kapacitor Template ID or type/script required for task #{self[:name]}"
      elsif self[:template_id].nil? and (self[:type].nil? or self[:script].nil?)
        raise ArgumentError, "Kapacitor type/script required for task #{self[:name]} when not using a Template ID"
      end

      raise ArgumentError, "Kapacitor task requires at least one database and retention policy" if (self[:dbrps].nil? or self[:dbrps].size == 0)
    end
  end

  newproperty(:enable) do
    desc "Whether the task should be enabled or not."

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

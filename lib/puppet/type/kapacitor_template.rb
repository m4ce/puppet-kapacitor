#
# kapacitor_template.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

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

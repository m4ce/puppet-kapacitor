require 'puppet/util/feature'

Puppet.features.add(:kapacitor_api, :libs => ["kapacitor/client"])

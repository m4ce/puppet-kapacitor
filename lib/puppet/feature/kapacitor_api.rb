#
# kapacitor_api.rb
#
# Author: Matteo Cerutti <matteo.cerutti@hotmail.co.uk>
#

require 'puppet/util/feature'

Puppet.features.add(:kapacitor_api, :libs => ["kapacitor/client"])

class kapacitor::config {
  file {
    [$kapacitor::config_dir, "${kapacitor::config_dir}/kapacitor.d"]:
      recurse => true,
      purge => $kapacitor::config_dir_purge;

    default:
      owner => "root",
      group => "root",
      mode => "0755",
      ensure => "directory"
  }

  if $kapacitor::config_file_manage {
    file {$kapacitor::config_file:
      owner => "root",
      group => "root",
      mode => "0644",
      content => epp("kapacitor/kapacitor.conf.epp", {'config' => generate_toml(deep_merge({'data_dir' => $kapacitor::data_dir}, $kapacitor::opts))}),
    }

    if $kapacitor::service_manage {
      case $kapacitor::service_provider {
        default: {
          File["${kapacitor::config_dir}/kapacitor.d"] {
            notify => Service[$kapacitor::service_name]
          }

          File[$kapacitor::config_file] {
            notify => Service[$kapacitor::service_name]
          }
        }
        "docker": {
          File["${kapacitor::config_dir}/kapacitor.d"] {
            notify => Docker_container[$kapacitor::service_name]
          }

          File[$kapacitor::config_file] {
            notify => Docker_container[$kapacitor::service_name]
          }
        }
      }
    }
  }
}

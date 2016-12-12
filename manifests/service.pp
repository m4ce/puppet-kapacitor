class kapacitor::service {
  if $kapacitor::service_manage {
    case $kapacitor::service_provider {
      default: {
        service {$kapacitor::service_name:
          ensure => $kapacitor::service_ensure,
          enable => $kapacitor::service_enable,
          subscribe => Package[keys($kapacitor::packages)]
        }
      }
      "docker": {
        docker_container {
          $kapacitor::service_name:
            * => $kapacitor::service_opts;

          default:
            image => $kapacitor::service_image,
            ensure => $kapacitor::service_ensure
        }

        if $kapacitor::service_enable {
          Docker_container[$kapacitor::service_name] {
            restart_policy => "unless-stopped"
          }
        }
      }
    }
  }
}

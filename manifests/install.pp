class kapacitor::install {
  $kapacitor::gem_dependencies.each |String $gem_name, Hash $gem| {
    package {$gem_name:
      * => $gem,
      provider => "puppet_gem"
    }
  }

  case $kapacitor::service_provider {
    "docker": {
      docker_image {$kapacitor::service_image: }
    }
    default: {
      $kapacitor::packages.each |String $package_name, Hash $package| {
        package {$package_name:
          * => $package
        }
      }
    }
  }
}

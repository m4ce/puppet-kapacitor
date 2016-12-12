class kapacitor::install {
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

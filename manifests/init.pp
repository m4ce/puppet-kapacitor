class kapacitor (
  Kapacitor::Templates $templates,
  Kapacitor::Tasks $tasks,
  String $data_dir,
  Hash $opts,
  String $config_dir,
  String $config_file,
  Boolean $config_file_manage,
  Hash $packages,
  Hash $gem_dependencies,
  Enum["default", "docker"] $service_provider,
  Hash $service_opts,
  String $service_image,
  String $service_name,
  Boolean $service_manage,
  Enum["present", "absent", "stopped", "running"] $service_ensure,
  Boolean $service_enable
) {
  include kapacitor::install
  include kapacitor::config
  include kapacitor::service

  $templates.each |String $template_name, Kapacitor::Template $template| {
    kapacitor_template {$template_name:
      * => $template
    }
  }

  $tasks.each |String $task_name, Kapacitor::Task $task| {
    kapacitor_task {$task_name:
      * => $task
    }
  }
}

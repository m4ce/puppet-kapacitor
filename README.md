# Puppet types and providers for Kapacitor

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with the kapacitor module](#setup)
4. [Reference - Types reference and additional functionalities](#reference)
5. [Hiera integration](#hiera)
6. [Contact](#contact)

<a name="overview"/>

## Overview

This module implements native types and providers to manage some aspects of Kapacitor. The providers are *fully idempotent*.

<a name="module-description"/>

## Module Description

The kapacitor module allows to automate the configuration and deployment of Kapacitor templates and tasks.

<a name="setup"/>

## Setup

The module requires the [kapacitor-ruby](https://rubygems.org/gems/kapacitor-ruby) rubygem. It also requires Puppet >= 4.0.0.

If you are using Puppet AIO, you may want to include the gem as part of the base installation. If not, you can install it as follows:

```
/opt/puppetlabs/puppet/bin/gem install kapacitor-ruby
```

Furthermore, on your puppet master, you'd need to install the [toml](https://rubygems.org/gems/toml) rubygem. If you use puppetserver, you can install it as follows:

```
puppetserver gem install toml
```

This is needed to generate Kapacitor's configuration file.

The include the main class as follows:

```
include kapacitor
```

<a name="reference"/>

## Reference

### Classes

#### kapacitor
`kapacitor`

```
include kapacitor
```

##### `templates` (optional)
Kapacitor templates in the form of {'template_name' => { .. }}

##### `tasks` (optional)
Kapacitor tasks in the form of {'task_name' => { .. }}

##### `opts` (optional)
Kapacitor daemon options in the form of {'option' => 'value'}.

Defaults to:
```
kapacitor::opts:
  hostname: "%{facts.networking.fqdn}"
  "skip-config-overrides": false
  "default-retention-policy": ""
  http:
    "bind-address": ":9092"
    "auth-enabled": false
    "log-enabled": true
    "write-tracing": false
    "pprof-enabled": false
    "https-enabled": false
  "config-override":
    enabled: true
  logging:
    file: "STDOUT"
    level: "INFO"
  replay:
    dir: "%{lookup('kapacitor::data_dir')}/replay"
  storage:
    boltdb: "%{lookup('kapacitor::data_dir')}/kapacitor.db"
  deadman:
    global: false
  smtp:
    enabled: false
    host: "localhost"
    port: 25
    username: ""
    password: ""
    "no-verify": false
    "idle-timeout": "30s"
    "global": false
    "state-changes-only": false
  slack:
    enabled: false
    global: false
    "state-changes-only": false
  opsgenie:
    enabled: false
  victorops:
    enabled: false
  pagerduty:
    enabled: false
  hipchat:
    enabled: false
  telegram:
    enabled: false
  sensu:
    enabled: false
  alerta:
    enabled: false
  reporting:
    enabled: false
  kubernetes:
    enabled: false
  talk:
    enabled: false
  stats:
    enabled: true
    "stats-interval": "10s"
    "database": "_kapacitor"
    "retention-policy": "autogen"
  udf:
    functions: {}
  collectd:
    enabled: false
  opentsdb:
    enabled: false
```

##### `data_dir` (optional)
Path to the Kapacitor data directory (default: /var/lib/kapacitor)

##### `gem_dependencies` (optional)
Rubygems dependencies for Kapacitor

Defaults to:
```
kapacitor::gem_dependencies:
  "kapacitor-ruby": {}
```

##### `packages` (optional)
Installation packages for Kapacitor

Defaults to:
```
kapacitor::packages:
  "kapacitor": {}
```

##### `config_dir` (optional)
Path to the Kapacitor configuration directory (default: /etc/kapacitor)

##### `config_file` (optional)
Path to the Kapacitor configuration file (default: /etc/kapacitor/kapacitor.conf)

##### `config_file_manage` (optional)
Whether we should manage Kapacitor's configuration file or not (default: true)

##### `service_provider` (optional)
Kapacitor service provider. Can be either 'default' or 'docker' (default: 'default')

##### `service_opts` (optional)
Kapacitor service options when using 'docker' as a provider.

##### `service_name` (optional)
Kapacitor service name (default: 'kapacitor')

##### `service_manage` (optional)
Whether we should manage the service runtime or not (default: true)

##### `service_ensure` (optional)
Whether the resource is running or not. Valid values are 'running', 'stopped'. (default: 'running')

##### `service_enable` (optional)
Whether the service is onboot enabled or not. Defaults to true.

### Types

#### kapacitor_template
`kapacitor_template` manages Kapacitor templates

```
kapacitor_template {"template_name": }
```

##### `name` (required)
Template name

##### `type` (required)
The template type: stream or batch.

##### `script` (required)
The content of the script.

##### `ensure` (optional)
Whether the resource is present or not. Valid values are 'present', 'absent'. Defaults to 'present'.

#### kapacitor_task
`kapacitor_task` manages Kapacitor tasks

```
kapacitor_task {"task_name": }
```

##### `name` (required)
Task name

##### `template_id` (optional)
An optional ID of a template to use instead of specifying a TICKscript and type directly.

##### `dbrps` (required)
List of database retention policy pairs the task is allowed to access.

##### `type` (optional)
The task type: stream or batch.

##### `script` (optional)
The content of the script.

##### `vars` (optional)
A set of vars for overwriting any defined vars in the TICKscript.

##### `enable` (optional)
Whether the task is enabled or not.

##### `ensure` (optional)
Whether the resource is present or not. Valid values are 'present', 'absent'. Defaults to 'present'.

#### kapacitor_topic_handler
`kapacitor_topic_handler` manages Kapacitor topic handlers

```
kapacitor_topic_handler {"<topic>:<handler>": }
```

##### `name` (required)
Composite namevar in the form of `<topic>:<handler>`.

##### `handler` (optional)
Handler name.

##### `topic` (optional)
Topic name.

##### `kind` (required)
The kind of handler.

##### `match` (optional)
A lambda expression to filter matching alerts.

##### `options` (optional)
Configurable options determined by the handler kind.

##### `ensure` (optional)
Whether the resource is present or not. Valid values are 'present', 'absent'. Defaults to 'present'.

<a name="hiera"/>

## Hiera integration

You can optionally define your Kapacitor tasks and templates.

```
---
kapacitor::templates:
  "cpu_template":
    type: "stream"
    script: |

    // Info threshold
    var info

    // Warning threshold
    var warn = 80

    // Critical threshold
    var crit = 90

    // How much data to window
    var period = 10s

    // Emit frequency
    var every = 10s

    var data = stream
        |from()
            .measurement('cpu')
            .groupBy('host')
            .where(lambda: "cpu" == 'cpu-total')
        |eval(lambda: 100.0 - "usage_idle")
             .as('used')
        |window()
             .period(period)
             .every(every)
        |mean('used')
             .as('stat')

    // Thresholds
    var alert = data
        |alert()
            .id('{{ index .Tags "host"}}/cpu_used')
            .message('{{ .ID }}:{{ index .Fields "stat" }}')
            .info(lambda: "stat" > info)
            .warn(lambda: "stat" > warn)
            .crit(lambda: "stat" > crit)
            .topic('cpu')
    ensure: "present"
kapacitor::tasks:
  "cpu_task":
    template_id: "cpu_template",
    dbrps:
      - db: "telegraf"
        rp: "autogen"
    vars:
      crit:
        value: 95
        type: int
    enable: true
    ensure: "present"
kapacitor::topic_handlers:
  "cpu:my_handler":
    kind: slack
    match: "changed()"
    options:
      channel: '#alerts'
    ensure: "present"
```

<a name="contact"/>

## Contact
Matteo Cerutti - matteo.cerutti@hotmail.co.uk

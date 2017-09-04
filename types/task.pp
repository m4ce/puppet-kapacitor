type Kapacitor::Task = Struct[{
  dbrps => Array[Struct[{
    db => String,
    rp => String
  }]],
  Optional[template_id] => String,
  Optional['type'] => Enum["stream", "batch"],
  Optional[script] => String,
  Optional[vars] => Hash[String, Struct[{
    "type" => Enum['bool', 'int', 'float', 'duration', 'string', 'regex', 'lambda', 'star', 'list'],
    value => Data
  }],
  Optional[enable] => Boolean,
  Optional[ensure] => Enum["present", "absent"]
}]

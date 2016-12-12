type Kapacitor::Task = Struct[{
  dbrps => Array[Struct[{
    db => String,
    rp => String
  }]],
  Optional[template_id] => String,
  Optional['type'] => Enum["stream", "batch"],
  Optional[script] => String,
  Optional[vars] => Hash,
  Optional[enable] => Boolean,
  Optional[ensure] => Enum["present", "absent"]
}]

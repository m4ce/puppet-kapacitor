type Kapacitor::Topic_handler = Struct[{
  Optional[topic] => String,
  Optional[actions] => Array[String],
  Optional[ensure] => Enum["present", "absent"]
}]

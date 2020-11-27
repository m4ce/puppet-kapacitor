type Kapacitor::Topic_handler = Struct[{
  Optional[topic] => String,
  kind => String,
  Optional[match] => String,
  Optional[options] => Hash,
  Optional[ensure] => Enum["present", "absent"]
}]

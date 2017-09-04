type Kapacitor::Template = Struct[{
  "type" => Enum["stream", "batch"],
  script => String,
  Optional[ensure] => Enum["present", "absent"]
}]

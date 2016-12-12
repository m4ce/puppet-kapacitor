type Kapacitor::Template = Struct[{
  type => Enum["stream", "batch"],
  script => String
}]

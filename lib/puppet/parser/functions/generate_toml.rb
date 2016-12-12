module Puppet::Parser::Functions
  newfunction(:generate_toml, :type => :rvalue, :doc => <<-EOS
This generate a TOML body from a Ruby hash
    EOS
  ) do |arguments|
    raise(Puppet::ParseError, "render_toml(): Wrong number of arguments " +
"given (#{arguments.size} for 1)") if arguments.size != 1

    arg = arguments.first
    unless arg.is_a?(Hash)
      raise Puppet::ParseError, ("#{arg.inspect} is not a Hash. It looks to be a #{arg.class}")
    end

    require 'toml'

    TOML::Generator.new(arg).body
  end
end

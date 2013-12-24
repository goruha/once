require 'chef/resource'

class Chef
  class Resource
    class Once < Chef::Resource

      identity_attr :name

      def initialize(name, run_context=nil)
        super
        @resource_name = :once
        @code = nil
        @cookbook = nil
        @name = name
        @action = :run
        @allowed_actions.push(:run)
      end

      def code(args=nil, &block)
        if block_given? then
          args = block
        end
        set_or_return(:code, args, {})
      end

      def cookbook(args=nil)
        set_or_return(:cookbook, args, {})
      end

      def name(args=nil)
        set_or_return(:name, args, {})
      end
    end
  end
end

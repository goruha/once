require 'chef/resource'

class Chef
  class Provider
    class Once < Chef::Provider
      require 'fileutils'
      include Chef::Mixin::Command

      def whyrun_supported?
        true
      end

      #######
      # Load resources
      def load_current_resource
        @current_resource = Chef::Resource::Once.new(@new_resource.name)
        @current_resource.code(@new_resource.code)
        @current_resource.cookbook(@new_resource.cookbook || @new_resource.cookbook_name)
        @current_resource
      end

      #######
      # Once run action
      def action_run
        updated = false
        unless had_run?
          instance_eval(&@current_resource.code)
          ran
          updated = true
        else
          Chef::Log.info("Once [#{@current_resource.cookbook}][#{@current_resource.name}] ran previously. Skip it.")
        end
        new_resource.updated_by_last_action(updated)
      end

      #######
      # Is Once Ran Flag Set?
      # Function that indicates if the particular once value for a cookbook
      # flag is set and true
      def had_run?
        had_run = false
        if Chef::Config[:solo]
          run_once_file = _get_run_file_path
          had_run = ::File::exists?(run_once_file)
        else
          had_run = node.attribute?(:once) &&
            node[:once].attribute?(@current_resource.cookbook) &&
            node[:once][@current_resource.cookbook].attribute?(@current_resource.name) &&
            node[:once][@current_resource.cookbook][@current_resource.name]
        end
        Chef::Log.debug("Once [#{@current_resource.cookbook}][#{@current_resource.name}] had_run: #{had_run}")
        had_run
      end

      #######
      # Get path to file that used as flag for run procedure?
      def _get_run_file_path
        run_once_dir = '/var/chef/cache/once/'
        unless ::File.directory?(run_once_dir)
          FileUtils.mkdir_p(run_once_dir)
        end
        "#{run_once_dir}#{@current_resource.cookbook}-#{@current_resource.name}.flag"
      end

      #######
      # Set Once Ran Flag
      # Function that sets the once ran value for the cookbook and flag
      def ran
        if Chef::Config[:solo]
          run_once_file = _get_run_file_path
          ::File.open(run_once_file, "w") {}
        else
          node.set[:once][@current_resource.cookbook][@current_resource.name] = true
        end
      end
    end
  end
end

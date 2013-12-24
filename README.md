Once Cookbook
=================
Manage actions in cookbooks that should only run once in both chef-solo and
chef-client.

Usage
-----
To use in your cookbooks, simply include the once recipe and use it as follow

    once "put name" do
      code do
        # put here chef DSL code
        execute "once exec example" do
          command "ls -l /"
        end
      end
    end

Attributes
----------
Once will determine which is the best way to store flag based upon which way
the recipe is run. If it is used by a recipe run by chef-solo, will store flag as
empty file in /var/chef/cache/once_flag/. When used
by a recipe run by chef-client, the node will have an tree of attributes under
`[:once]` in the format `[:once][COOKBOOK][NAME]`.

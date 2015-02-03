require 'chef/resource'
require 'json'

class Chef
  class Resource
    class Tainer < Chef::Resource
      provides :tainer, :on_platforms => :all

      def initialize(name, run_context=nil)
        super
        @resource_name = :tainer
        @allowed_actions.push(:create)
        @action = :create
        # We deliberately delay this requirement until the resource is used.
        # I don't like this, but I prefer putting it here over vendoring the gem
        # and having a new release of the cookbook any time we want to advance the gem
        # used.
        require 'tainers'
      end

      def specification(arg=nil)
        arg = self.class.normalize_specification(arg) unless arg.nil?
        set_or_return(
          :specification,
          arg,
          :required => true
        )
      end

      def retry_attempts(arg=3)
        set_or_return(
          :retry_attempts,
          arg,
          :kind_of => Integer
        )
      end

      def tainer
        @tainer ||= Tainers.specify(specification)
      end

      # Given `params` Hash-like, ensures the Hash is of a form that the docker-api will accept,
      # meaning:
      # - Keys are strings
      # - Values are Hashes, Arrays, Strings, or Numbers only
      #
      # Rather than validate, this creates a new hash by converting the original to JSON and back again.
      # This has the happy effect of reducing things to the types that the API understands.  Symbols will
      # automatically go to strings.
      #
      # Returns a new Hash with values converted as it's able.
      def self.normalize_specification params
        JSON.parse(params.to_json)
      end
    end
  end
end


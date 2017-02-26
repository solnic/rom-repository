require 'dry/core/inflector'

module ROM
  class Repository
    # TODO: look into making command graphs work without the root key in the input
    #       so that we can get rid of this wrapper
    #
    # @api private
    class CommandProxy
      attr_reader :command, :root

      def initialize(command)
        @command = command
      end

      def call(input)
        command.call(command.name.relation => input)
      end

      def >>(other)
        self.class.new(command >> other)
      end
    end
  end
end

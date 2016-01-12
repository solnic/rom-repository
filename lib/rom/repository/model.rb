module ROM
  class Repository
    class Model < Repository
      def self.[](name)
        klass = Class.new(self) { relations(name) }
        klass
      end

      attr_reader :create_command

      def initialize(rom)
        super
        @create_command = Commands::Create[adapter].build(relation, result: :one)
      end

      def create(attributes)
        create_command.call(attributes)
      end

      private

      def relation
        __send__(relation_name).relation
      end

      def relation_name
        self.class.relations[0]
      end

      def adapter
        relation.class.adapter
      end
    end
  end
end

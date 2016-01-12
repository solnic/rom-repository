module ROM
  class Repository
    class Model < Repository
      def self.[](name)
        klass = Class.new(self) { relations(name) }
        klass
      end

      attr_reader :create_command

      attr_reader :update_command

      attr_reader :delete_command

      def initialize(rom)
        super
        @create_command = Commands::Create[adapter].build(relation, result: :one)
        @update_command = Commands::Update[adapter].build(relation, result: :one)
        @delete_command = Commands::Delete[adapter].build(relation, result: :one)
      end

      def create(attributes)
        create_command.call(attributes)
      end

      def update(pk, attributes)
        update_command
          .new(relation.where(relation.primary_key => pk))
          .call(attributes)
      end

      def delete(pk)
        delete_command
          .new(relation.where(relation.primary_key => pk))
          .call
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

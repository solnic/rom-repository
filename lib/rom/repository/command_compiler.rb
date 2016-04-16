require 'concurrent/map'

require 'rom/setup/finalize/commands'
require 'rom/commands'
require 'rom/repository/command_proxy'

module ROM
  class Repository
    class CommandCompiler
      SUPPORTED_TYPES = %i[create update delete].freeze

      def self.[](*args)
        cache.fetch_or_store(args.hash) do
          container, type, adapter, ast, block = args

          unless SUPPORTED_TYPES.include?(type)
            raise ArgumentError, "#{type.inspect} is not a supported command type"
          end

          graph_opts = new(type, adapter, container, registry, block).visit(ast)

          command = ROM::Commands::Graph.build(registry, graph_opts)

          if command.graph?
            CommandProxy.new(command)
          else
            command.unwrap
          end
        end
      end

      def self.cache
        @__cache__ ||= Concurrent::Map.new
      end

      def self.registry
        @__registry__ ||= Hash.new { |h, k| h[k] = {} }
      end

      attr_reader :type, :adapter, :container, :registry, :block

      def initialize(type, adapter, container, registry, block)
        @type = Commands.const_get(Inflector.classify(type))[adapter]
        @registry = registry
        @container = container
        @block = block
      end

      def visit(ast)
        name, node = ast
        __send__(:"visit_#{name}", node)
      end

      def visit_relation(node)
        name, meta, header = node
        base_name = meta[:base_name]
        other = visit(header)

        mapping =
          if meta[:combine_type] == :many
            base_name
          else
            { Inflector.singularize(name).to_sym => base_name }
          end

        register_command(base_name, type, meta)

        if other.size > 0
          [mapping, [type, other]]
        else
          [mapping, type]
        end
      end

      def visit_header(node)
        node.map { |n| visit(n) }.compact
      end

      def visit_attribute(node)
        nil
      end

      def register_command(name, type, meta)
        klass = type.create_class(name, type)

        if meta[:combine_type]
          klass.use(:associates)
          klass.associates(:parent, key: meta[:keys].invert.to_a.flatten)
        end

        relation = container.relations[name]

        # TODO: this is a copy-paste from rom's FinalizeCommands, we are missing
        #       an interface!
        gateway = container.gateways[relation.class.gateway]
        gateway.extend_command_class(klass, relation.dataset)

        if type.restrictable
          klass.send(:include, finalizer.relation_methods_mod(relation.class))
        end

        result = meta.fetch(:combine_type, :one)

        klass.instance_exec(&block) if block

        registry[name][type] = klass.build(relation, result: result)
      end

      # @api private
      def finalizer
        # TODO: we only need `relation_methods_mod` so would be nice to expose it
        #       as a class method instead
        @finalizer ||= Finalize::FinalizeCommands.new(container.relations, nil, nil)
      end
    end
  end
end

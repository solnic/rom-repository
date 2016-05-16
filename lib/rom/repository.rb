require 'rom/support/deprecations'
require 'rom/support/options'

require 'rom/repository/mapper_builder'
require 'rom/repository/relation_proxy'
require 'rom/repository/command_compiler'

require 'rom/repository/root'

module ROM
  # Abstract repository class to inherit from
  #
  # @api public
  class Repository
    # @deprecated
    class Base < Repository
      def self.inherited(klass)
        super
        Deprecations.announce(self, 'inherit from Repository instead')
      end
    end

    attr_reader :container

    attr_reader :relations

    attr_reader :mappers

    # Create a root-repository class and set its root relation
    #
    # @api public
    def self.[](name)
      klass = Class.new(self < Repository::Root ? self : Repository::Root)
      klass.relations(name)
      klass.root(name)
      klass
    end

    # @api private
    def self.inherited(klass)
      super

      return if self === Repository

      klass.relations(*relations)
      klass.commands(*commands)
    end

    # Define which relations your repository is going to use
    #
    # @example
    #   class MyRepo < ROM::Repository::Base
    #     relations :users, :tasks
    #   end
    #
    #   my_repo = MyRepo.new(rom_env)
    #
    #   my_repo.users
    #   my_repo.tasks
    #
    # @return [Array<Symbol>]
    #
    # @api public
    def self.relations(*names)
      if names.any?
        attr_reader(*names)

        if defined?(@relations)
          @relations.concat(names).uniq!
        else
          @relations = names
        end

        @relations
      else
        @relations
      end
    end

    # @api public
    def self.commands(*names, **opts)
      if names.any? || opts.any?
        @commands = names + opts.to_a

        @commands.each do |spec|
          type, *view = Array(spec).flatten

          if view.size > 0
            define_restricted_command_method(type, view)
          else
            define_command_method(type)
          end
        end
      else
        @commands || []
      end
    end

    def self.define_command_method(type)
      define_method(type) do |*args|
        command(type => self.class.root).call(*args)
      end
    end

    def self.define_restricted_command_method(type, views)
      views.each do |view_name|
        meth_name = views.size > 1 ? :"#{type}_#{view_name}" : type

        define_method(meth_name) do |*args|
          view_args, *input = args

          command(type => self.class.root)
            .public_send(view_name, *view_args)
            .call(*input)
        end
      end
    end

    # @api private
    def initialize(container)
      @container = container
      @mappers = MapperBuilder.new
      @relations = {}

      self.class.relations.each do |name|
        relation = container.relation(name)

        proxy = RelationProxy.new(
          relation, name: name, mappers: mappers, registry: relations
        )

        instance_variable_set("@#{name}", proxy)

        relations[name] = proxy
      end
    end

    # Create a command for a relation
    #
    # @example
    #   create_user = repo.command(:create, repo.users)
    #
    #   create_user_with_task = repo.command(:create, repo.users.combine_children(one: repo.tasks))
    #
    # @param [Symbol] type Type of the command
    # @param [Repository::RelationProxy] relation
    #
    # @return [ROM::Command]
    #
    # @api public
    def command(*args, mapper: nil, **opts, &block)
      all_args = args + opts.to_a.flatten

      if all_args.size > 1
        commands.fetch_or_store(all_args.hash) do
          type, name = args + opts.to_a.flatten

          relation = name.is_a?(Symbol) ? relations[name] : name

          ast = relation.to_ast
          adapter = relations[relation.name].adapter

          if mapper
            use_mapper = container.mappers[relation.name][mapper]
          else
            use_mapper = mappers[ast]
          end

          CommandCompiler[container, type, adapter, ast] >> use_mapper
        end
      else
        container.command(*args, &block)
      end
    end

    private

    def commands
      @__commands__ ||= Concurrent::Map.new
    end
  end
end

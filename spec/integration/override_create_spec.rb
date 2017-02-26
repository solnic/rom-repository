RSpec.describe ROM::Repository, '.command' do
  it 'should use customer create command' do
    config = ROM::Configuration.new(:memory)

    config.relation(:accounts) do
      register_as :accounts   

      # avoid pulling in plugin, use :key_inference
      def base_name
        name
      end
    end

    class CreateAccount < ROM::Commands::Create[:memory]
      relation :accounts
      register_as :create
      result :one

      def execute(tuple)
        byebug
      end
    end

    config.register_command(CreateAccount)

    rom = ROM.container(config)

    account_repo = Class.new(ROM::Repository[:accounts]) do
      commands :create
    end

    repo = account_repo.new(rom)


    expect(repo.command(create: :accounts).left.class).
      to eq(CreateAccount)
  end
end

require 'ostruct'

RSpec.describe 'Repository with a customer mapper' do
  include_context 'database'
  include_context 'relations'
  include_context 'seeds'

  let(:repo) { repo_class.new(rom) }
  let(:repo_class) do
    Class.new(ROM::Repository::Base) do
      relations :users

      def all_users
        users.all
      end
    end
  end

  before do
    setup.mappers do
      define(:users) do
        register_as :custom_user
        model OpenStruct
      end
    end
  end

  it 'maps to my model' do
    expect(repo.all_users.as(:custom_user).to_a).to be_an Array
    expect(repo.all_users.as(:custom_user).to_a.first).to be_an OpenStruct
  end
end

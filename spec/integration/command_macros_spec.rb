RSpec.describe ROM::Repository, '.command' do
  include_context 'database'
  include_context 'relations'
  include_context 'plugins'

  it 'allows configuring a create command' do
    repo = Class.new(ROM::Repository[:users]) do
      commands :create
    end.new(rom)

    user = repo.create(name: 'Jane')

    expect(user.id).to_not be(nil)
    expect(user.name).to eql('Jane')
  end

  it 'allows configuring an update and delete commands' do
    repo = Class.new(ROM::Repository[:users]) do
      commands :create, update: :by_id, delete: :by_id
    end.new(rom)

    user = repo.create(name: 'Jane')

    repo.update(user.id, name: 'Jane Doe')

    user = repo.users.by_id(user.id).one

    expect(user.name).to eql('Jane Doe')

    repo.delete(user.id)

    expect(repo.users.by_id(user.id).one).to be(nil)
  end

  it 'allows defining a single command with multiple views' do
    repo = Class.new(ROM::Repository[:users]) do
      commands :create, update: [:by_id, :by_name]
    end.new(rom)

    user = repo.create(name: 'Jane')

    repo.update_by_id(user.id, name: 'Jane Doe')
    user = repo.users.by_id(user.id).one
    expect(user.name).to eql('Jane Doe')

    repo.update_by_name(user.name, name: 'Jane')
    user = repo.users.by_id(user.id).one
    expect(user.name).to eql('Jane')
  end

  it 'allows to pass a block to configure command class' do
    repo = Class.new(ROM::Repository[:users]) do
      command(:create) do
        use :upcase_name
      end
    end.new(rom)

    user = repo.create(name: 'Jane')

    persisted_user = repo.users.by_id(user.id).one
    expect(persisted_user.name).to eql('JANE')
  end

  it 'allows to pass a block with view syntax' do
    repo = Class.new(ROM::Repository[:users]) do
      command :create
      command update: :by_id do
        use :upcase_name
      end
    end.new(rom)

    user = repo.create(name: 'Jane')

    repo.update(user.id, name: 'Jane Doe')

    updated_user = repo.users.by_id(user.id).one

    expect(updated_user.name).to eql('JANE DOE')
  end
end

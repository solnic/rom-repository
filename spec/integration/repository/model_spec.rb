require 'rom/repository/model'

RSpec.describe ROM::Repository::Model do
  subject(:repo) { ROM::Repository::Model[:users].new(rom) }

  include_context 'database'

  before do
    configuration.relation(:users)
  end

  describe '#create' do
    it 'inserts tuple into relation' do
      user_tuple = repo.create(name: 'Jane')
      user_struct = repo.users.where(id: user_tuple[:id]).one

      expect(user_struct.to_h).to eql(user_tuple)
    end
  end

  describe '#update' do
    it 'updates existing tuple in a relation' do
      user_tuple = repo.create(name: 'Jane')

      repo.update(user_tuple[:id], name: 'Jane Doe')

      user_struct = repo.users.where(id: user_tuple[:id]).one

      expect(user_struct.name).to eql('Jane Doe')
    end
  end

  describe '#delete' do
    it 'deletes existing tuple from a relation' do
      user_tuple = repo.create(name: 'Jane')

      repo.delete(user_tuple[:id])

      user_struct = repo.users.where(id: user_tuple[:id]).first

      expect(user_struct).to be(nil)
    end
  end
end

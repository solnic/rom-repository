require 'rom/repository/model'

RSpec.describe ROM::Repository::Model do
  subject(:repo) { ROM::Repository::Model[:users].new(rom) }

  include_context 'database'

  describe '#create' do
    it 'inserts tuple into relation' do
      user_tuple = repo.create(name: 'Jane')
      user_struct = repo.users.where(id: user_tuple[:id]).one

      expect(user_struct.to_h).to eql(user_tuple)
    end
  end
end

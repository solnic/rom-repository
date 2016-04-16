RSpec.shared_context 'relations' do
  let(:users) { rom.relation(:users) }
  let(:tasks) { rom.relation(:tasks) }
  let(:tags) { rom.relation(:tags) }

  before do
    configuration.relation(:users) do
      def by_id(id)
        where(id: id)
      end

      def by_name(name)
        where(name: name)
      end

      def all
        select(:id, :name).order(:name, :id)
      end

      def find(criteria)
        where(criteria)
      end
    end

    configuration.relation(:tasks) do
      def find(criteria)
        where(criteria)
      end

      def for_users(users)
        where(user_id: users.map { |u| u[:id] })
      end
    end

    configuration.relation(:tags)

    configuration.relation(:accounts) do
      dataset :user_accounts

      def name
        :accounts
      end

      def for_users(users)
        where(owner_id: users.map { |u| u[:id] })
      end
    end
  end
end

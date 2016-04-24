RSpec.shared_context 'database' do
  let(:configuration) { ROM::Configuration.new(:sql, uri) }
  let(:conn) { configuration.gateways[:default].connection }
  let(:rom) { ROM.container(configuration) }
  let(:uri) { 'postgres://localhost/rom_repository' }

  before do
    conn.loggers << LOGGER

    [:tags, :tasks, :user_accounts, :users].each { |table| conn.drop_table?(table) }

    conn.create_table :users do
      primary_key :id
      column :name, String
    end

    conn.create_table :tasks do
      primary_key :id
      foreign_key :user_id, :users, null: false, on_delete: :cascade
      column :title, String
    end

    conn.create_table :tags do
      primary_key :id
      foreign_key :task_id, :tasks, null: false, on_delete: :cascade
      column :name, String
    end

    conn.create_table :user_accounts do
      primary_key :account_id
      column :account_no, String
      foreign_key :owner_id, :users, null: false, on_delete: :cascade
    end
  end
end

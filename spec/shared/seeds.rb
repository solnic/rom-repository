RSpec.shared_context 'seeds' do
  before do
    jane_id = conn[:users].insert name: 'Jane'
    joe_id = conn[:users].insert name: 'Joe'

    conn[:tasks].insert user_id: joe_id, title: 'Joe Task'
    task_id = conn[:tasks].insert user_id: jane_id, title: 'Jane Task'

    conn[:tags].insert task_id: task_id, name: 'red'

    conn[:user_accounts].insert owner_id: jane_id, account_no: 'A-645'
  end
end

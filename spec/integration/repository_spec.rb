RSpec.describe 'ROM repository' do
  include_context 'database'
  include_context 'relations'
  include_context 'seeds'
  include_context 'structs'

  it 'loads a single relation' do
    expect(repo.all_users.to_a).to match_array([jane, joe])
  end

  it 'can be used with a custom mapper' do
    expect(repo.all_users_as_users.to_a).to match_array([
      Test::Models::User.new(jane),
      Test::Models::User.new(joe)
    ])
  end

  it 'loads a relation by an association' do
    expect(repo.tasks_for_users(repo.all_users)).to match_array([jane_task, joe_task])
  end

  it 'loads a combine relation with one parent' do
    expect(repo.task_with_user.first).to eql(task_with_user)
  end

  it 'loads a combine relation with one parent with custom tuple key' do
    expect(repo.task_with_owner.first).to eql(task_with_owner)
  end

  it 'loads a combined relation with many children' do
    expect(repo.users_with_tasks.to_a).to match_array([jane_with_tasks, joe_with_tasks])
  end

  it 'loads a combined relation with one child' do
    expect(repo.users_with_task.to_a).to match_array([jane_with_task, joe_with_task])
  end

  it 'loads a combined relation with one child restricted by given criteria' do
    expect(repo.users_with_task_by_title('Joe Task').to_a).to match_array([
      jane_without_task, joe_with_task
    ])
  end

  it 'loads nested combined relations' do
    expect(repo.users_with_tasks_and_tags.first.to_h).to eql(user_with_task_and_tags.to_h)
  end

  it 'loads a wrapped relation' do
    expect(repo.tag_with_wrapped_task.first).to eql(tag_with_task)
  end

  it 'loads a relation by an association with custom keys' do
    expect(repo.accounts_for_users(repo.all_users)).to match_array([jane_account])
  end

  it 'loads a combine relation with many children and custom keys' do
    expect(repo.users_with_accounts.to_a).to match_array([jane_with_accounts, joe_without_accounts])
  end
end

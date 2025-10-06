Before('@requires_login') do
  user_data = {
    netid: 'student1',
    email: 'student1@test.com',
    first_name: 'John',
    last_name: 'Doe',
    active: true
  }
  @current_user = User.create!(user_data)
  login_as('student1')
end
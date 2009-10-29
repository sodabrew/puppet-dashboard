class User
  generator_for :login, :start => 'user00001'
  generator_for :password, "password"
  generator_for :password_confirmation, "password"
end

# Be sure to restart your server when you modify the secret_token.

# The secret_token is used to verify the integrity of signed cookies.
# User sessions will be invalidated when this value changes, which
# may require them to log out and back into the application.

# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.

if SETTINGS.secret_token
  PuppetDashboard::Application.config.secret_token = SETTINGS.secret_token
elsif ENV['SECRET_TOKEN'].present?
  PuppetDashboard::Application.config.secret_token = ENV['SECRET_TOKEN']
end

# Check that users have generated an alternate secret_token for production
if !(%w(development test).include? Rails.env) &&
   PuppetDashboard::Application.config.secret_token == 'b1bbd28f6f9ebfc25f09da9bff4643f75d5ad8c8da8b60234168c81cd6d32c15e5e5421196ee99da248d37d84f73c9ecb38608fc0d8b2709872290a3f43b244e'

  # Do not raise an error if secret token is not available during assets precompilation
  if ENV['RAILS_GROUPS'] != 'assets'
    raise <<-ERROR

  You must generate a unique secret token for your Puppet Dashboard instance.

      echo "secret_token: '$(bundle exec rake secret)'" >> config/settings.yml

  ERROR
  end
end

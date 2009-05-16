# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_larry_session',
  :secret      => 'b1bbd28f6f9ebfc25f09da9bff4643f75d5ad8c8da8b60234168c81cd6d32c15e5e5421196ee99da248d37d84f73c9ecb38608fc0d8b2709872290a3f43b244e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store

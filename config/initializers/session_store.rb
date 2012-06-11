# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
Hrt::Application.config.session_store :cookie_store, :key => "_resource_tracking_session"

# Use the database for sessions instead of the cookie-based default,
# # which shouldn't be used to store highly confidential information
# # (create the session table with "rails generate session_migration")
# # Hrt::Application.config.session_store :active_record_store

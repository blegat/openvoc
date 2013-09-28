# Be sure to restart your server when you modify this file.

#Openvoc::Application.config.session_store :cookie_store, key: '_openvoc_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
Openvoc::Application.config.session_store :active_record_store

# I use this because I find it more reliable and that way
# I don't need to check because it is no more user input

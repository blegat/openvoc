# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
Openvoc::Application.config.secret_token = '6d598b3061b2e43101e26532b89e15cfe0e1472c5f5f730b444d3cd4f52a85464ac406b6a14d4c480b5e0c1f84994ee56fa66115d50f0e4d273283e01d76a576'
Openvoc::Application.config.secret_key_base = 'xx6d598b3061b2e43101e26532b89e15cfe0e1472c5f5f730b444d3cd4f52a85464ac406b6a14d4c480b5e0c1f84994ee56fa66115d50f0e4d273283e01d76a576'
# TODO In Rails 4 the configuration option in this file has been renamed from secret_token to secret_key_base. We’ll need to specify both options while we’re transitioning from Rails 3 but once we’ve successfully migrated our application we can remove the secret_token option. It’s best to use a different token for our secret_key_base.
# http://railscasts.com/episodes/415-upgrading-to-rails-4?view=asciicast

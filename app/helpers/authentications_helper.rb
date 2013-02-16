module AuthenticationsHelper
  def provider_image(provider, size)
    image_tag "#{provider}_#{size}.png",
      size: "#{size}x#{size}", alt: provider_name(provider)
  end
  def provider_name(provider)
    if 'open_id' == provider
      'OpenID'
    elsif 'google_oauth2' == provider
      'Google'
    else
      provider.titleize
    end
  end
end

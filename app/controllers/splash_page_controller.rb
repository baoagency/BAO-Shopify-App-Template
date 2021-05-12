class SplashPageController < ApplicationController
  include ShopifyApp::EmbeddedApp
  include ShopifyApp::RequireKnownShop
  include ShopifyApp::ShopAccessScopesVerification

  rescue_from ActiveResource::UnauthorizedAccess do
    redirect_to(shop_login)
  end

  def index
    @host = host
    @shop_origin = current_shopify_domain

    # required to trigger OAuth token check
    shop = Shop.find_by_shopify_domain(current_shopify_domain)
    shop.with_shopify_session do
      ShopifyAPI::Shop.current
    end
  end

  def host
    return params[:host] if params.has_key? :host

    uri = URI.parse(params[:return_to])

    Rack::Utils.parse_nested_query(uri.query)['host']
  end
end

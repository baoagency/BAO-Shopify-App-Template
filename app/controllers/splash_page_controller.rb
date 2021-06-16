class SplashPageController < ApplicationController
  include ShopifyApp::EmbeddedApp
  include ShopifyApp::RequireKnownShop
  include ShopifyApp::ShopAccessScopesVerification

  # rescue_from ActiveResource::UnauthorizedAccess do
  #   redirect_to(shop_login)
  # end

  def index
    @host = host
    shopify_host_cookie.set(host) if shopify_host_cookie.empty?
    @shop_origin = current_shopify_domain

    # required to trigger OAuth token check
    shop = Shop.find_by_shopify_domain(current_shopify_domain)
    shop.with_shopify_session do
      ShopifyAPI::Shop.current
    end
  end

  def host
    return shopify_host_cookie.get if shopify_host_cookie.exists?
    return params[:host] if params.has_key? :host

    uri = URI.parse(params[:return_to])

    Rack::Utils.parse_nested_query(uri.query)['host']
  end

  private

    def shopify_host_cookie
      @shopify_host_cookie ||= ShopifyHostCookie.new(cookies)
    end
end

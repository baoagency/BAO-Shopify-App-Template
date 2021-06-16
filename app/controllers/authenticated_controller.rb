# frozen_string_literal: true

class AuthenticatedController < ApplicationController
  include ShopifyApp::EnsureAuthenticatedLinks
  include ShopifyApp::Authenticated

  before_action :shop_origin
  before_action :set_shop
  before_action :set_host

  private

    def shop_origin
      @shop_origin ||= current_shopify_domain
    end

    def set_shop
      @shop = Shop.find_by_shopify_domain(shop_origin)
    end

    def set_host
      if shopify_host_cookie.exists?
        @host = shopify_host_cookie.get

        return
      end

      host = params.key?(:host) ? params[:host] : nil

      if host
        @host = host

        shopify_host_cookie.set(host)

        return
      end

      if params[:return_to]
        uri = URI.parse(params[:return_to])

        host = Rack::Utils.parse_nested_query(uri.query)['host'] unless host

        @host = host

        shopify_host_cookie.set(host)

        return
      end

      @host = nil
    end

    def shopify_host_cookie
      @shopify_host_cookie ||= ShopifyHostCookie.new(cookies)
    end
end

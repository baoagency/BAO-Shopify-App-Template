# frozen_string_literal: true

class AuthenticatedController < ApplicationController
  include ShopifyApp::EnsureAuthenticatedLinks
  include ShopifyApp::Authenticated

  before_action :shop_origin
  before_action :set_shop

  private

  def shop_origin
    @shop_origin ||= current_shopify_domain
  end

  def set_shop
    @shop = Shop.find_by_shopify_domain(shop_origin)
  end
end

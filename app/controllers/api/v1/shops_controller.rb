# frozen_string_literal: true

class Api::V1::ShopsController < AuthenticatedController
  before_action :set_shop, only: %i[me show]

  def show
  end

  def me
  end

  private

  def set_shop
    @shop = Shop.find_by(shopify_domain: current_shopify_domain)
  end
end

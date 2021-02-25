class PagesController < AuthenticatedController
  def index
    @products = ShopifyAPI::Product.find(:all, params: { limit: 10 })
  end

  def about
    @products = ShopifyAPI::Product.find(:all, params: { limit: 10 })
  end
end

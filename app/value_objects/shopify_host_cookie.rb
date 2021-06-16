class ShopifyHostCookie
  KEY = :shopify_host

  def initialize(cookies)
    @cookies = cookies
  end

  def get
    @cookies[KEY] if exists?
  end

  def set(value)
    @cookies[:shopify_host] = {
      value: value,
      expires: 1.day.from_now,
    }
  end

  def exists?
    @cookies.key? KEY
  end

  def empty?
    !exists?
  end
end

require 'spree/localized_number'

module Spree
  Price.class_eval do
    after_save :refresh_products_cache

    # TODO: this method override can be removed when updating to Spree 2.3
    def price=(price)
      self[:amount] = Spree::LocalizedNumber.parse(price)
    end


    private

    def refresh_products_cache
      variant.andand.refresh_products_cache
    end
  end
end

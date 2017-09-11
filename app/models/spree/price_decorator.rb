module Spree
  Price.class_eval do
    after_save :refresh_products_cache


    private

    def refresh_products_cache
      variant.andand.refresh_products_cache
    end

    # We override this method for users to enter prices with dot or comma indifferently
    # In Spree 2.3 it will be moved to Spree::LocalizedNumber.parse
    # See https://github.com/spree/spree/commit/b817dab4a95c1beda3f18e42f0efcd2b7e64312a
    def parse_price(price)
      return price.to_d unless price.is_a?(String)

      price = price.gsub(/[^\d.,]/, '')  # Replace all Currency Symbols, Letters and -- from the string
      if price =~ /^.*[\.,]\d{1}$/       # If string ends in a single digit (e.g. ,2)
        price += "0"                     # make it ,20 in order for the result to be in "cents"
      end
      unless price =~ /^.*[\.,]\d{2}$/   # If does not end in ,00 / .00 then
        price += "00"                    # add trailing 00 to turn it into cents
      end
      price = price.gsub(/[\.,]/, '')    # Replace all (.) and (,) so the string result becomes in "cents"
      price.to_d / 100                   # Let to_decimal do the rest
    end
  end
end

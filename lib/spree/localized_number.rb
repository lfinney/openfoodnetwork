module Spree
  class LocalizedNumber
    def self.parse(number)
      return number.to_d unless number.is_a?(String)

      number = number.gsub(/[^\d.,]/, '')  # Replace all Currency Symbols, Letters and -- from the string

      if number =~ /^.*[\.,]\d{1}$/        # If string ends in a single digit (e.g. ,2)
        number += "0"                      # make it ,20 in order for the result to be in "cents"
      end

      unless number =~ /^.*[\.,]\d{2}$/    # If does not end in ,00 / .00 then
        number += "00"                     # add trailing 00 to turn it into cents
      end

      number = number.gsub(/[\.,]/, '')    # Replace all (.) and (,) so the string result becomes in "cents"
      number.to_d / 100                    # Let to_decimal do the rest
    end
  end
end

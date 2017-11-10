module OpenFoodNetwork
  class StandingOrderPaymentUpdater
    def initialize(order)
      @order = order
    end

    def update!
      return if payment.blank?

      if card_required? && !card_set?
        return unless ensure_credit_card
      end

      payment.update_attributes(amount: @order.outstanding_balance)
    end

    private

    def payment
      @payment ||= @order.pending_payments.last
    end

    def card_required?
      payment.payment_method.type == Spree::Gateway::StripeConnect
    end

    def card_set?
      payment.source is_a? Spree::CreditCard
    end

    def ensure_credit_card
      return false unless saved_credit_card.present?
      payment.update_attributes(source: saved_credit_card)
    end

    def saved_credit_card
      @order.standing_order.credit_card
    end
  end
end
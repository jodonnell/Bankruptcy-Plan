class Payments
  attr_reader :creditor, :payments, :left_over

  def initialize payment, creditors
    @payment = payment
    @creditors = creditors
  end

  def make_payments 
    split_payment = @payment.to_f
    while money_owed_to_creditors? && split_payment > 0
      split_payment = pay_and_return_extra(split_payment / @creditors.size)
    end
    split_payment
  end

  def money_owed_to_creditors?
    creditors_still_owed_money = @creditors.select { |creditor| creditor.amount_owed != 0 }
    creditors_still_owed_money.size != 0
  end


  def pay_and_return_extra split_payment
    extra_amount = 0
    remove = []
    @creditors.each_with_index do |creditor, index|
      if creditor.amount_owed > split_payment
        creditor.amount_owed -= split_payment
      else
        extra_amount += split_payment - creditor.amount_owed
        creditor.amount_owed = 0
        remove << index
      end
    end

    remove.sort.reverse.each { |index| @creditors.delete_at index}

    extra_amount
  end


end

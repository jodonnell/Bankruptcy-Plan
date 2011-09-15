require './payment'

class Payments
  attr_reader :creditor, :payments, :left_over

  def initialize payment, creditors
    @payment = payment
    @creditors = creditors
  end

  def make_payments 
    @payments = []
    num_extra_pennies = 0
    split_payment = @payment
    while money_owed_to_creditors? && split_payment > 0
      num_extra_pennies += split_payment % @creditors.size
      split_payment = pay_and_return_extra(split_payment / @creditors.size)
    end

    num_extra_pennies = pay_out_rounding_pennies num_extra_pennies if @creditors.size > 0

    condense_payments

    split_payment + num_extra_pennies
  end

  def condense_payments
    @payments.each_with_index do |payment, index|
      @payments.each_with_index do |payment2, index_inner|
        if (payment.creditor == payment2.creditor) && index_inner != index
          payment.payment += payment2.payment
          @payments.delete_at index_inner
        end
      end
    end

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
        make_payment creditor, split_payment
      else
        extra_amount += split_payment - creditor.amount_owed
        make_payment creditor, creditor.amount_owed
        remove << index
      end
    end

    remove.sort.reverse.each { |index| @creditors.delete_at index}

    extra_amount
  end

  def pay_out_rounding_pennies extra_pennies
    pennies_paid_out = 0
    extra_pennies.times do |index| 
      pennies_paid_out += 1
      next_creditor = index % @creditors.size
      @creditors[next_creditor].amount_owed -= 1
      @payments.each { |p| p.payment += 1 if p.creditor == @creditors[next_creditor]}
      puts "please email me the input figures, this report may be wrong" if @creditors[index % @creditors.size].amount_owed < 0
    end
    extra_pennies - pennies_paid_out
  end

  private
  def make_payment creditor, amount
    creditor.amount_owed -= amount
    @payments << Payment.new(creditor, amount)
  end
end

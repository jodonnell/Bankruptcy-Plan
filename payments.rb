class Payments
  attr_reader :creditor, :payments, :left_over

  def initialize payment, creditors
    @payment = payment
    @creditors = creditors
  end

  def make_payments 
    num_extra_pennies = 0
    split_payment = @payment
    while money_owed_to_creditors? && split_payment > 0
      num_extra_pennies += split_payment % @creditors.size
      split_payment = pay_and_return_extra(split_payment / @creditors.size)
    end

    num_extra_pennies = pay_out_rounding_pennies num_extra_pennies if @creditors.size > 0

    split_payment + num_extra_pennies
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

  def pay_out_rounding_pennies extra_pennies
    pennies_paid_out = 0
    extra_pennies.times do |index| 
      pennies_paid_out += 1
      @creditors[index % @creditors.size].amount_owed -= 1
      puts "please email me the input figures, this report may be wrong" if @creditors[index % @creditors.size].amount_owed < 0
    end
    extra_pennies - pennies_paid_out
  end
end

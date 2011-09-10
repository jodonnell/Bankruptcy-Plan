require './payment'

class BankruptcyPlan
  attr_reader :monthly_payment, :total_amount, :amount_owed_to_trustee

  def initialize priority_creditors, secured_creditors, unsecured_amount, num_months, split_at
    @priority_creditors = priority_creditors
    @secured_creditors = secured_creditors
    @unsecured_amount = unsecured_amount
    @num_months = num_months.to_f
    @split_at = split_at - 1

    calc_total_amount
    calc_monthly_payment
    calc_amount_owed_to_trustee
  end

  def calc_total_amount
    sum = 0
    @priority_creditors.each {|creditor| sum += creditor.amount_owed}
    @secured_creditors.each {|creditor| sum += creditor.amount_owed}
    sum += @unsecured_amount
    @total_amount = sum.round(2)
  end

  def calc_monthly_payment
    @monthly_payment = round_penny(unrounded_monthly_payment)
  end

  def unrounded_monthly_payment
    @total_amount / @num_months
  end

  def calc_amount_owed_to_trustee
    @amount_owed_to_trustee = round_penny((unrounded_monthly_payment * @num_months) / 0.9)
  end

  def next_month
    @payments = []
    @this_months_amount = @monthly_payment
    pay_priority_creditors if @priority_creditors.size > 0
    pay_secured_creditors if (@secured_creditors.size > 0 and @this_months_amount > 0)
    pay_unsecured_creditors if @unsecured_amount > 0 and @this_months_amount > 0
    @payments
  end

  def pay_unsecured_creditors

  end

  def pay_secured_creditors
    
  end

  def pay_priority_creditors
    if @split_at <= 0
      split_payment @priority_creditors
    else
      pay_one_way
    end
  end

  def split_payment creditors
    split_amount = @this_months_amount / creditors.size
    odd = false
    if (split_amount.round(2) * creditors.size) > @this_months_amount
      odd = true
      split_amount -= 0.01
    end

    next_amount = split_amount
    creditors.each_with_index do |priority_creditor, index|
      amount = next_amount
      next_amount = split_amount

      if index == (creditors.size - 1) and odd
        amount = amount + 0.01
      end
      payment = Payment.new(priority_creditor, amount)
      
      if payment.left_over > 0
        next_amount = split_amount + payment.left_over

      end
      @payments << payment
    end
    @this_months_amount = next_amount
  end    

  def pay_one_way
    payment = Payment.new(@priority_creditors[0], @this_months_amount)
    if payment.left_over > 0
      @priority_creditors.shift
      @split_at -= 1
      @this_months_amount = payment.left_over
      pay_one_way
    else
      @this_months_amount = 0
    end
    @payments << payment
  end

  def round_penny money
    (money * 100).ceil / 100.0
  end

end

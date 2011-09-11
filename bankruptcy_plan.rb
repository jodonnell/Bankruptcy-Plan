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
    split_payment @secured_creditors
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

  def split_amounts creditors
    split_amount = (@this_months_amount * 100).to_i / creditors.size
    num_balance = (@this_months_amount * 100).to_i % creditors.size
    splits = []
    creditors.each_with_index do |c, index| 
      if index < num_balance
        splits << split_amount + 0.01 
      else
        splits << split_amount
      end
    end
    splits
  end

  def split_payment creditors
    split_amounts = split_amounts creditors

    creditors.each_with_index do |priority_creditor, index|
      payment = Payment.new(priority_creditor, split_amounts[index])
      
      if payment.left_over > 0
        split_amounts[index + 1] = split_amounts[index + 1] + payment.left_over
      end

      if payment.left_over == 0 and (index == (creditors.size - 1))
        next_amount = 0
      end

      @payments << payment
    end
    @this_months_amount = next_amount
  end    

  def pay_one_way
    payment = Payment.new(@priority_creditors[0], @this_months_amount)
    if payment.left_over > 0
      payment_finished payment.left_over
    else
      @this_months_amount = 0
    end
    @payments << payment
  end

  def payment_finished left_over
    @priority_creditors.shift
    @split_at -= 1
    @this_months_amount = left_over
    pay_one_way
  end

  def round_penny money
    (money * 100).ceil / 100.0
  end

end

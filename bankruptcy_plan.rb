require './payment'
require './payments'

class BankruptcyPlan
  attr_reader :monthly_payment, :total_amount, :amount_owed_to_trustee_per_month

  def initialize priority_creditors, secured_creditors, unsecured_creditor, num_months, split_at
    @priority_creditors = priority_creditors
    @secured_creditors = secured_creditors
    @unsecured_creditor = unsecured_creditor
    @num_months = num_months.to_f
    @split_at = split_at - 1
    @total_amount_paid_to_unsecured = 0
    calc_total_amount
    calc_monthly_payment
    calc_amount_owed_to_trustee
  end

  def calc_total_amount
    sum = 0
    @priority_creditors.each {|creditor| sum += creditor.amount_owed}
    @secured_creditors.each {|creditor| sum += creditor.amount_owed}
    sum += @unsecured_creditor.amount_owed
    @total_amount = sum
  end

  def calc_monthly_payment
    @monthly_payment = unrounded_monthly_payment.ceil
  end

  def unrounded_monthly_payment
    @total_amount / @num_months.to_f
  end

  def calc_amount_owed_to_trustee
    total_owed_to_trustee = ((unrounded_monthly_payment * @num_months) / 0.9).ceil
    @amount_owed_to_trustee_per_month = (total_owed_to_trustee / @num_months).ceil
  end

  def next_month
    @payments = []
    @this_months_amount = @monthly_payment
    pay_priority_creditors if @priority_creditors.size > 0
    pay_secured_creditors if (@secured_creditors.size > 0 and @this_months_amount > 0)
    pay_unsecured_creditors if @unsecured_creditor.amount_owed > 0 and @this_months_amount > 0
    @payments.flatten
  end

  def pay_unsecured_creditors
    payments = Payments.new @this_months_amount, [@unsecured_creditor]
    @this_months_amount = payments.make_payments
    @payments << payments.payments
  end

  def pay_secured_creditors
    payments = Payments.new @this_months_amount, @secured_creditors
    @this_months_amount = payments.make_payments
    @payments << payments.payments
  end

  def pay_priority_creditors
    if @split_at <= 0
      payments = Payments.new @monthly_payment, @priority_creditors
      @this_months_amount = payments.make_payments
      @payments = payments.payments
    else
      @this_months_amount = @monthly_payment
      pay_one_way
    end
  end

  def pay_one_way
    payments = Payments.new @this_months_amount, [@priority_creditors[0]]
    @this_months_amount = payments.make_payments

    if @this_months_amount > 0
      payment_finished @this_months_amount
    else
      @this_months_amount = 0
    end
    @payments << payments.payments[0]
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

require './payment'

class BankruptcyPlan
  attr_reader :monthly_payment, :total_amount, :amount_owed_to_trustee

  def initialize priority_creditors, secured_creditors, unsecured_amount, num_months
    @priority_creditors = priority_creditors
    @secured_creditors = secured_creditors
    @unsecured_amount = unsecured_amount
    @num_months = num_months.to_f

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
    payments = []
    if @priority_creditors.size > 0
      this_months_amount = @monthly_payment
      if @priority_creditors[0].amount_owed < @monthly_payment
        payments << Payment.new(@priority_creditors[0], @priority_creditors[0].amount_owed.round(2))
        this_months_amount -= @priority_creditors[0].amount_owed
        @priority_creditors.shift
      end
      @priority_creditors[0].amount_owed -= this_months_amount
      payments << Payment.new(@priority_creditors[0], this_months_amount)
    end
  end

  def round_penny money
    (money * 100).ceil / 100.0
  end

end

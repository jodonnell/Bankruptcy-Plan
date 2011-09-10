class Payment
  attr_reader :creditor, :payment, :left_over
  def initialize c, p, make_payment=true
    @creditor = c
    if p > @creditor.amount_owed
      @left_over = p - @creditor.amount_owed
      @payment = round_penny @creditor.amount_owed.round(2)
    else
      @left_over = 0
      @payment = round_penny p
    end
    @creditor.amount_owed -= @payment if make_payment
  end

  def round_penny money
    (money * 100).ceil / 100.0
  end

  def ==(other)
    @creditor == other.creditor and @payment == other.payment
  end

  def to_s
    "#{@creditor.name} $#{@payment} remaining: #{@left_over} creditor owed #{@creditor.amount_owed}"
  end
end

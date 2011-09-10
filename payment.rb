class Payment
  attr_reader :creditor, :payment
  def initialize c, p
    @creditor = c
    @payment = round_penny p
  end

  def round_penny money
    (money * 100).ceil / 100.0
  end

  def ==(other)
    @creditor == other.creditor and @payment == other.payment
  end
end

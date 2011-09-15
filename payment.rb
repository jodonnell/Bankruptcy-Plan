class Payment
  attr_accessor :creditor, :payment
  def initialize c, p
    @creditor = c
    @payment = p
  end

  def ==(other)
    @creditor == other.creditor and @payment == other.payment
  end

  def to_s
    "#{ @creditor.name } %0.2f" % [(@payment / 100.0).round(2)]
  end


end

class Creditor
  attr :name
  attr_accessor :amount_owed

  def initialize name, amount_owed
    @name = name
    @amount_owed = amount_owed
  end
end

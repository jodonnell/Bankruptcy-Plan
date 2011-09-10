class Input
  def self.priority_creditors
    gets.chomp.to_i
  end

  def self.secured_creditors
    gets.chomp.to_i
  end

  def self.name
    gets.chomp
  end

  def self.amount_owed
    gets.chomp
  end

  def self.start_split
    gets.chomp
  end
end

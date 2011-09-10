require './input'
require './creditor'

puts "Number of priority creditors: "
num_priority = Input.priority_creditors

puts "Number of secured creditors: "
num_secured = Input.secured_creditors

priority_creditors = []
num_priority.times do
  priority_creditors << get_creditor 'priority'
  puts "Start spit?"
  start_splite_at = Input.start_split
end

secured_creditors = []
num_secured.times do
  secured_creditors << get_creditor 'secured'
end

puts "Amount owed to unsecured creditors: "
unsecured_amount = Input.amount_owed

bp = BankruptcyPlan.new priority_creditors, secured_creditors, unsecured_amount
bp.print


def get_creditor type
  puts "Name of #{type} creditor: "
  name = Input.name

  puts "Amount owed: "
  owed = Input.amount_owed
  Creditor.new name, owed
end

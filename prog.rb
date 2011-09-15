require './input'
require './creditor'
require './bankruptcy_plan'

def get_creditor type
  print "Name of #{type} creditor: "
  name = Input.name

  print "Amount owed: "
  owed = Input.amount_owed
  Creditor.new name, owed
end


print "Number of priority creditors: "
num_priority = Input.priority_creditors

print "Number of secured creditors: "
num_secured = Input.secured_creditors

priority_creditors = []
num_priority.times do
  priority_creditors << get_creditor('priority')
end

secured_creditors = []
num_secured.times do
  secured_creditors << get_creditor('secured')
end

print "Amount owed to unsecured creditors: "
unsecured_amount = Input.amount_owed
unsecured_creditor = Creditor.new 'Unsecured', unsecured_amount

print "Months: "
months = Input.get_month

print "Split at: "
split_at = Input.start_split

# priority_creditors = [Creditor.new('Apple Law', 1750_00), Creditor.new('Child Support', 500_00), Creditor.new('IRS', 400_00)]
# secured_creditors = [Creditor.new('Toyota', 4000_00), Creditor.new('Honda', 200_00), Creditor.new('Donkey Store', 150_01)]
# unsecured_creditor = Creditor.new('Unsecured', 11000_00)
# months = 60
# split_at = 2

bp = BankruptcyPlan.new priority_creditors, secured_creditors, unsecured_creditor, months, split_at
month = 1
while (payments = bp.next_month).size > 0
  print "Month #{month}: "
  print payments
  puts
  month +=1
end

print "Amount owed to trustee: "
puts "%0.2f" % [(bp.amount_owed_to_trustee_per_month / 100.0).round(2)]

require './spec/spec_helper'
require './bankruptcy_plan'
require './creditor'

describe BankruptcyPlan do

  before(:each) do
    @apple_law = Creditor.new('Apple Law', 1750_00)
    @child_support = Creditor.new('Child Support', 500_00)
    @irs = Creditor.new('IRS', 400_00)

    @toyota = Creditor.new('Toyota', 4000_00)
    @honda = Creditor.new('Honda', 200_00)
    @donkey = Creditor.new('Donkey Store', 150_01)

    priority_creditors = [@apple_law, @irs, @child_support]
    secured_creditors = [@toyota, @honda, @donkey]
    
    @bankruptcy_plan = BankruptcyPlan.new priority_creditors, secured_creditors, 11000_00, 60, 2
  end

  it 'can sum its debt' do
    @bankruptcy_plan.total_amount.should == 18000_01
  end

  it 'can get the rounded monthly payment' do
    @bankruptcy_plan.monthly_payment.should == 300_01
  end

  it 'can get the amount owed to the trustee' do
    @bankruptcy_plan.amount_owed_to_trustee.should == 20000_02
  end

  it 'can get the creditors for the next month' do
    payment = Payment.new @apple_law, 300_01
    @bankruptcy_plan.next_month.should == [payment]
  end

  it 'can correctly split payments' do
    payments = [Payment.new(@irs, 50_06), Payment.new(@apple_law, 249_95)]
    5.times { @bankruptcy_plan.next_month }
    @bankruptcy_plan.next_month.should == payments
  end

  it 'can correctly split priority payments' do
    payments = [Payment.new(@irs, 150_01), Payment.new(@child_support, 150_00)]
    6.times { @bankruptcy_plan.next_month }
    @bankruptcy_plan.next_month.should == payments
  end

  it 'can handle more' do
    payments = [Payment.new(@irs, 49_94), Payment.new(@child_support, 199_98),
                Payment.new(@toyota, 16_69), Payment.new(@honda, 16_70),
                Payment.new(@donkey, 16_70),
               ]
    8.times { @bankruptcy_plan.next_month }
    @bankruptcy_plan.next_month.should == payments
  end

end

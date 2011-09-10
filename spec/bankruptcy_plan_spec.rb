require './bankruptcy_plan'
require './creditor'
require 'rspec'

describe BankruptcyPlan do

  before(:each) do
    @apple_law = Creditor.new('Apple Law', 1750)
    @child_support = Creditor.new('Child Support', 500)
    @irs = Creditor.new('IRS', 400)

    priority_creditors = [
                          @apple_law,
                          @irs,
                          @child_support
                          ]

    secured_creditors = [
                         Creditor.new('Toyota', 4000),
                         Creditor.new('Honda', 200),
                         Creditor.new('Donkey Store', 150.01),
                        ]
    
    @bankruptcy_plan = BankruptcyPlan.new priority_creditors, secured_creditors, 11000, 60, 2
  end

  it 'can sum its debt' do
    @bankruptcy_plan.total_amount.should == 18000.01
  end

  it 'can get the rounded monthly payment' do
    @bankruptcy_plan.monthly_payment.should == 300.01
  end

  it 'can get the amount owed to the trustee' do
    @bankruptcy_plan.amount_owed_to_trustee.should == 20000.02
  end

  it 'can get the creditors for the next month' do
    payment = Payment.new @apple_law, 300.01, false
    @bankruptcy_plan.next_month.should == [payment]
  end

  it 'can correctly split payments' do
    payments = [Payment.new(@irs, 50.06, false), Payment.new(@apple_law, 249.95, false)]
    5.times { @bankruptcy_plan.next_month }
    @bankruptcy_plan.next_month.should == payments
  end

  it 'can correctly split priority payments' do
    payments = [Payment.new(@irs, 150, false), Payment.new(@child_support, 150.01, false)]
    6.times { @bankruptcy_plan.next_month }
    @bankruptcy_plan.next_month.should == payments
  end

  it 'can handle more' do
    payments = [Payment.new(@irs, 49.94, false), Payment.new(@child_support, 199.98, false)]
    8.times { @bankruptcy_plan.next_month }
    @bankruptcy_plan.next_month.should == payments
  end

end

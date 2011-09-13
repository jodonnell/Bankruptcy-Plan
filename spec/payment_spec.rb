require './payments'
require './creditor'
require 'rspec'

describe Payments do
  before(:each) do
    @apple_law = Creditor.new('Apple Law', 1750)
    @child_support = Creditor.new('Child Support', 500)
    @irs = Creditor.new('IRS', 400)
  end

  it 'can do a simple split' do
    payments = Payments.new(1200, [@apple_law, @child_support, @irs])
    leftover = payments.make_payments

    @apple_law.amount_owed.should == 1350
    @child_support.amount_owed.should == 100
    @irs.amount_owed.should == 0
    leftover.should == 0
  end

  it 'can split where one creditor does not need full payment' do
    payments = Payments.new(1500, [@apple_law, @child_support, @irs])
    leftover = payments.make_payments

    @apple_law.amount_owed.should == 1150
    @child_support.amount_owed.should == 0
    @irs.amount_owed.should == 0
    leftover.should == 0
  end

  it 'can handle overflow' do
    payments = Payments.new(2750, [@apple_law, @child_support, @irs])
    leftover = payments.make_payments

    @apple_law.amount_owed.should == 0
    @child_support.amount_owed.should == 0
    @irs.amount_owed.should == 0
    leftover.should == 100
  end


end

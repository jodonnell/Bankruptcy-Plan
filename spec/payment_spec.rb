require './spec/spec_helper'
require './payments'
require './creditor'

describe Payments do
  before(:each) do
    @apple_law = Creditor.new('Apple Law', 1750_00)
    @child_support = Creditor.new('Child Support', 500_00)
    @irs = Creditor.new('IRS', 400_00)
  end

  it 'can do a simple split' do
    payments = Payments.new(1200_00, [@apple_law, @child_support, @irs])
    leftover = payments.make_payments

    @apple_law.amount_owed.should == 1350_00
    @child_support.amount_owed.should == 100_00
    @irs.amount_owed.should == 0
    leftover.should == 0
  end

  it 'can split where one creditor does not need full payment' do
    payments = Payments.new(1500_00, [@apple_law, @child_support, @irs])
    leftover = payments.make_payments

    @apple_law.amount_owed.should == 1150_00
    @child_support.amount_owed.should == 0
    @irs.amount_owed.should == 0
    leftover.should == 0
  end

  it 'can handle overflow' do
    payments = Payments.new(2750_00, [@apple_law, @child_support, @irs])
    leftover = payments.make_payments

    @apple_law.amount_owed.should == 0
    @child_support.amount_owed.should == 0
    @irs.amount_owed.should == 0
    leftover.should == 100_00
  end

  it 'can deal with extra pennies' do
    payments = Payments.new(100_00, [@apple_law, @child_support, @irs])
    leftover = payments.make_payments

    @apple_law.amount_owed.should == 1716_66
    @child_support.amount_owed.should == 466_67
    @irs.amount_owed.should == 366_67
    leftover.should == 0
  end

  it 'can correctly split pennies' do
    payments = Payments.new(300_01, [@apple_law, @child_support])
    leftover = payments.make_payments
    payments.payments[0].payment.should == 150_01
    payments.payments[1].payment.should == 150_00
  end


end

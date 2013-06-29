# == Schema Information
#
# Table name: payments
#
#  id                  :integer          not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  paid_at             :datetime
#  payer_id            :integer
#  payee_id            :integer
#  event_id            :integer
#  amount_cents        :integer
#  event_user_id       :integer
#  processor_fee_cents :integer
#  our_fee_cents       :integer
#  cash                :boolean          default(FALSE)
#  paid_amount_cents   :integer
#  debit_uri           :string(255)
#

require 'spec_helper'

describe Payment do
  
  before { @payment = FactoryGirl.create(:payment) }
  subject { @payment }
  it { should be_valid }

  describe "attributes" do
    [:requested_at,
     :paid_at,
     :due_at,
     :payer_id,
     :payee_id,
     :event_id,
     :amount_cents,
     :event_user_id,
     :transaction_id].each do |attribute|
      it { should respond_to(attribute) }
    end
  end

  describe "validations" do
    it { should validate_presence_of(:payer_id) }
    it { should validate_presence_of(:payee_id) }
    it { should validate_presence_of(:event_id) }
    it { should validate_presence_of(:event_user_id) }
    it { should validate_presence_of(:event_user_id) }
    it { should validate_presence_of(:amount) }
    it { should allow_value("$1234").for(:amount) }
    it { should_not allow_value("abcd").for(:amount) }

    describe "after paid with cash" do
      before { @payment.pay! }
      it { should_not validate_presence_of(:transaction_id) }
    end

    describe "after paid with other method" do
      it { should validate_presence_of(:transaction_id) }
    end
  end

  describe "mass assignment" do
    # [:requested_at,
    #  :paid_at,
    #  :payer_id,
    #  :payee_id,
    #  :event_id,
    #  :amount,
    #  :event_user_id,
    #  :transaction_id,
    #  :payment_method].each do |attribute|
    #   it { should_not allow_mass_assignment_of(attribute) }
    # end
  end

  describe "relationships" do
    it { should belong_to(:payer).class_name("User") }
    it { should belong_to(:payee).class_name("User") }
    it { should belong_to(:event) }
    it { should belong_to(:event_user) }
  end

  describe "callbacks" do
    it "should set relevant values" do
      @payment.requested_at.to_s.should == @payment.event.created_at.to_s
      @payment.due_at.to_s.should == @payment.event.due_at.to_s
      @payment.processor_fee_amount_cents.should_not be_nil
      @payment.our_fee_amount_cents.should_not be_nil
    end
  end

  describe "pay! method" do
    before do
      @payment.pay!
    end

    it { @payment.paid_at.should_not be_nil }
  end

end

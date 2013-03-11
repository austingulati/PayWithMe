# == Schema Information
#
# Table name: event_users
#
#  id               :integer          not null, primary key
#  event_id         :integer
#  user_id          :integer
#  amount_cents     :integer          default(0)
#  due_at           :datetime
#  paid_at          :datetime
#  invitation_sent  :boolean          default(FALSE)
#  payment_id       :integer
#  visited_event    :boolean          default(FALSE)
#  paid_with_cash   :boolean          default(TRUE)
#  paid_total_cents :integer          default(0)
#

class EventUser < ActiveRecord::Base
  
  # Accessible attributes
  attr_accessible :event_id, :user_id
  monetize :amount_cents, allow_nil: true
  monetize :paid_total_cents, allow_nil: true

  # Relationships
  belongs_to :user, class_name: "User", foreign_key: "user_id"
  belongs_to :event
  has_many :payments

  # Validations
  validates :due_at, presence: true, if: :member?
  validates :user_id, presence: true
  validates :event_id, presence: true

  # Callbacks
  # before_validation :copy_event_attributes
  # after_initialize :copy_event_attributes
  # after_save :copy_event_attributes

  def paid?
  	paid_at.present?
  end

  def visit_event!
    if !visited_event?
      toggle(:visited_event).save
    end
  end

  def amount_present?
    self.amount.present?
  end

  def member?
    self.event.present? && self.event.organizer != self.user
  end

  def organizer?
    self.event.present? && self.event.organizer == self.user
  end

  # def paid_total_cents
  #   payments.where("paid_at IS NOT NULL").sum(&:amount_cents)
  # end

  def create_payment(options={})
    copy_event_attributes
    current_cents = options[:amount_cents] || amount_cents
    payment_method = PaymentMethod.find_by_id(options[:payment_method] || PaymentMethod::MethodType::CASH)
    if current_cents > amount_cents
      return false
    end

    payment = user.sent_payments.find_or_create_by_payee_id_and_event_id_and_event_user_id_and_amount_cents_and_payment_method_id_and_paid_at(
      payee_id: event.organizer.id,
      event_id: event.id,
      event_user_id: self.id,
      amount_cents: current_cents,
      payment_method_id: payment_method.id,
      paid_at: nil
    )
  end

  def pay!(payment, options={})
    copy_event_attributes
    payment.pay!(options)

    update_paid_total_cents
    update_paid_with_cash
    self.save
    true
  end

  # def paid_with_cash?
  #   self.payments.where('payment_method_id != ?', PaymentMethod::MethodType::CASH).count > 0
  # end
  
  def unpay_cash_payments!
    copy_event_attributes
    self.payments.where(payment_method_id: PaymentMethod::MethodType::CASH).destroy_all

    update_paid_total_cents
    update_paid_with_cash
    self.save
  end

  def unpay!(payment)
    copy_event_attributes
    payment.unpay!

    update_paid_total_cents
    update_paid_with_cash
    self.save
  end

private
  def copy_event_attributes
    if self.event.present? && self.member?
      self.due_at = self.event.due_at
      self.amount_cents = self.event.split_amount_cents
    end
  end

  def update_paid_with_cash
    self.paid_with_cash = true
    self.payments.each do |payment|
      self.paid_with_cash = false unless payment.payment_method_id == PaymentMethod::MethodType::CASH
    end
  end

  def update_paid_total_cents
    self.paid_total_cents = 0
    self.payments.each do |payment|
      self.paid_total_cents += payment.amount_cents if payment.paid_at.present?
    end

    if self.paid_total_cents >= self.amount_cents
      self.paid_at = Time.now
    else
      self.paid_at = nil
    end
  end

end
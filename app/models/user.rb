# == Schema Information
#
# Table name: users
#
#  id                         :integer          not null, primary key
#  email                      :string(255)      default(""), not null
#  encrypted_password         :string(255)      default(""), not null
#  reset_password_token       :string(255)
#  reset_password_sent_at     :datetime
#  remember_created_at        :datetime
#  sign_in_count              :integer          default(0)
#  current_sign_in_at         :datetime
#  last_sign_in_at            :datetime
#  current_sign_in_ip         :string(255)
#  last_sign_in_ip            :string(255)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  name                       :string(255)
#  provider                   :string(255)
#  uid                        :string(255)
#  profile_image_file_name    :string(255)
#  profile_image_content_type :string(255)
#  profile_image_file_size    :integer
#  profile_image_updated_at   :datetime
#  profile_image_url          :string(255)
#

class User < ActiveRecord::Base
  
  # Devise modules
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Accessible attributes
  attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :profile_image_option, :profile_image, :profile_image_option, :profile_image_url
  attr_accessor :profile_image_option
  has_attached_file :profile_image, styles: { thumb: "#{Figaro.env.thumb_size}x#{Figaro.env.thumb_size}>", small: "#{Figaro.env.small_size}x#{Figaro.env.small_size}>", medium: "#{Figaro.env.medium_size}x#{Figaro.env.medium_size}>" }
  
  # Callbacks
  before_save :set_profile_image

  # Relationships
  has_many :organized_events, class_name: "Event", foreign_key: "organizer_id"
  has_and_belongs_to_many :member_events, class_name: "Event", join_table: "event_users"
  has_many :messages

  def profile_image_type
    if profile_image.present?
      :upload
    elsif profile_image_url.present?
      :url
    else
      :gravatar
    end
  end

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_create do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name if auth.info.name
      user.email = auth.info.email if auth.info.email
    end
  end

  def self.new_with_session(params, session)
    if session["devise.user_attributes"]
      new(session["devise.user_attributes"], without_protection: true) do |user|
        user.attributes = params
        user.valid?
      end
    else
      super
    end
  end

  def self.search_by_name_and_email(name)
    User.where("name LIKE '%#{name}%' OR email LIKE '%#{name}%'")
  end

  def password_required?
    super && provider.blank?
  end

  def update_with_password(params, *options)
    # set_profile_image
    if encrypted_password.blank?
      update_attributes(params, *options)
    else
      super
    end
  end

private
  def set_profile_image
    if self.profile_image_option != "url"
      self.profile_image_url = nil
    end
    if self.profile_image_option != "upload"
      self.profile_image = nil
    end

    profile_image_option = nil
  end
end
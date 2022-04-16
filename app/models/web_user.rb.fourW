class WebUser < ActiveRecord::Base
  default_scope select([:id, :first_name, :last_name, :ui_state, :web_user_id,
    :account_type, :active, :password, :email_address, :company_name,
    :phone_number, :is_first_login])

  include Authentication
  include Authentication::ByPassword

  def self.customer
    where account_type: "C"
  end

  validates :web_user_id, presence: true, uniqueness: true

  has_many :customer_ownerships, class_name: "WebUserCustomerItem", foreign_key: :web_user
  has_many :customers, through: :customer_ownerships

  # TODO: implement me
  attr_accessible :new_password, :new_password_confirmation

  def full_name
    "#{first_name} #{last_name}"
  end

  def change_password(password, password_confirmation)
    self.new_password = password
    self.new_password_confirmation = password_confirmation

    return false if !valid?

    self.set_password(password)
  end

  def ui_state_object
    return {} if ui_state.blank?

    begin
      ActiveSupport::JSON.decode(ui_state)
    rescue ActiveSupport::JSON::ParseError
      {}
    end
  end

  def forgot_password!
    new_password = WebUser.generate_password
    self.change_password(new_password, new_password)
  end

  # Authenticates a user by their username and unencrypted password.  Returns the user or nil.
  def self.authenticate(username, password)
    u = find_by_web_user_id_and_account_type_and_active(username, "C", true)
    u && u.authenticated?(password) ? u : nil
  end

  protected
  def self.generate_password(length = 10)
    #generate a random password consisting of strings and digits
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    newpass = ""
    1.upto(length) { |i| newpass << chars[rand(chars.size-1)] }
    newpass
  end
end

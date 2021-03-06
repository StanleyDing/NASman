class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,  request_keys: [:provider] ##, :validatable
  devise :omniauthable, omniauth_providers: [:facebook, :dropbox]

  before_create :set_provider

  validates :name, presence: true
  #validates :email, uniqueness: {scope: :provider}


  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid.to_i).first_or_create do |user|
      # "first_or_create" method tries to load the first record.
      # If it fails, then "create" is called.
      # This method automatically sets "provider" and "uid"
      user.name = auth.info.name
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.oauth_token = auth.credentials.token
      #user.oauth_expires_at = Time.at(auth.credentials.expires_at)##
      user.image = auth.info.image
      user.save!
    end 
  end 

  def facebook
    @facebook ||= Koala::Facebook::API.new(oauth_token) 
  end 


  private
  def set_provider
    self.provider ||= "NAS"
  end
end

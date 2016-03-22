class User < ActiveRecord::Base
	has_many :events, dependent: :destroy

	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable,
	     :recoverable, :rememberable, 
	     :trackable, :validatable,
	     :confirmable, :lockable,
	     :omniauthable, :registerable


	validates :name, presence: true
	validates :name, uniqueness: true, if: -> { self.name.present? }

	#----- socialization -----
	acts_as_follower
	#-----

	def password_required?
		super if confirmed?
	end

	def password_match?
		self.errors[:password] << "can't be blank" if password.blank?
        self.errors[:password_confirmation] << "can't be blank" if password_confirmation.blank?
        self.errors[:password_confirmation] << "does not match password" if password != password_confirmation
        password == password_confirmation && !password.blank?
	end
end

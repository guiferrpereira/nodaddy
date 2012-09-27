module NoDaddy
	class Account
		include Mongoid::Document

		belongs_to :batch
		
		field :username, type: String
		field :password, type: String
		field :email_username, type: String
		field :email_password, type: String
	end
end

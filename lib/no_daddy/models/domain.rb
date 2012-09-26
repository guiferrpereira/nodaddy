module NoDaddy
	class Domain 
		include Mongoid::Document
		
		belongs_to :batch

		field :url,                 type: String
		field :expire_date,         type: Date
		field :status,              type: String
		field :unlocked,            type: Boolean
		field :auth_code_sent,      type: Boolean
		
		field :name_servers_old,    type: Array
		field :name_servers_new,    type: Array
		field :go_daddy_errors,     type: Array

		field :created_at,          type: Time
		field :updated_at,          type: Time
	end
end
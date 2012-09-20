# keep it simple stupid - account usename is a field in domain object, 
#   rather than a nested object.

# class NoDaddy::Account
# 	include Mongoid::Document
# 	embedded_in :domain
# 	field :username, type: String 	
# end

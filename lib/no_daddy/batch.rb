module NoDaddy
	class Batch
		include Mongoid::Document

		field :number, type: Integer
	end
end

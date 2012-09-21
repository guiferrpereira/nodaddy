module NoDaddy
  class Batch
    include Mongoid::Document

    has_one   :account
    has_many  :domains

    field :number,            type: Integer
    
    field :started,           type: Boolean
    field :finished,          type: Boolean
    field :ready,             type: Boolean

    field :operations, type: Array
  end
end

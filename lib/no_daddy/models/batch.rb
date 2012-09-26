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

    def domains_expired
      domains.where(:expire_date.lt => Time.now)
    end

    def domains_expiring_between(time1, time2)
      domains.between(:expire_date => time1..time2)
    end

    def domains_active
      domains.where(:status => 'Active')
    end
  end
end

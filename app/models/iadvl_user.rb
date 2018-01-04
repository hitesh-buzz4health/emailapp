class IadvlUser
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,                      :type => String,  :default => ''
  field :email,                     :type => String
  field :country_code,              :type => String, :default => "IN"
  field :phone,                     :type => String

end
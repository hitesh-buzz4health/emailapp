class IactaUser
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,                      :type => String,  :default => ''
  field :email,                     :type => String
  field :country_code,              :type => String
  field :country_name,              :type => String, :default => "unknown"
  field :phone,                     :type=> String

  field :specializations,           :type => Array, :default => []

end
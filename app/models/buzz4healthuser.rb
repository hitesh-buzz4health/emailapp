
class Buzz4healthUser
  include Mongoid::Document
  include Mongoid::Timestamps
     include Mongoid::FullTextSearch

  

  field :name,                      :type => String, :limit => 100, :default => '', :null => true
  field :email,                     :type => String
  field :country_code,              :type => String
  field :country_name,              :type => String, :default => "unknown"

  field :avatar_url,                :type => String #Url of the avatar image on Cloudinary
  field :user_persona,              :type => String, :default => ""
  field :verified,                  :type => Boolean, :default => false
  field :specializations,           :type => Array, :default => []


  
end

class ExternalDbUser
  include Mongoid::Document
  include Mongoid::Timestamps 

  field :name,                      :type => String,  :default => ''
  field :email,                     :type => String
  field :country_code,              :type => String
  field :country_name,              :type => String, :default => "unknown"

  field :avatar_url,                :type => String #Url of the avatar image on Cloudinary
  field :user_persona,              :type => String, :default => "doctor"
  field :verified,                  :type => Boolean, :default => false
  field :specializations,           :type => Array, :default => []
  field :practice,                  :type => String,  :default => ''
  field :address,                   :type => String,  :default => ''
  field :city,                      :type => String,  :default => ''
  field :state,                     :type => String,  :default => ''
  field :zip,                       :type => String,  :default => ''
  field :county,                    :type => String,  :default => ''
  field :phone,                     :type => String,  :default => ''
  field :fax,                       :type => String,  :default => ''
  field :gender,                    :type => String,  :default => ''
  field :title,                     :type => String,  :default => ''
  field :sic_code,                  :type => String,  :default => ''
  field :website,                   :type => String,  :default => ''


  
end
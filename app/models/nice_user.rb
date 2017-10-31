class NiceUser
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,                      :type => String
  field :email,                     :type => String
  field :phone,                     :type => String
  field :token ,                    :type => String 
  field :platform,                  :type => String 
  field :friends_list ,             :type => Array 
  field :fb_token ,                 :type => String 
  field :url  ,                     :type => String 
  field :uid,                       :type => String 
  field :avatar,                    :type => String 
  field :version_code ,             :type => String
  field :sdk_version  ,             :type => String 
  field :device_id  ,              :type => String 



 def as_json(options={}){
     
     :id => id.to_s,
     :name => name ,
     :email => email,
     :phone => phone,
     :url  => url ,
     :uid => uid,
     :avatar => avatar


  }
  end 

end

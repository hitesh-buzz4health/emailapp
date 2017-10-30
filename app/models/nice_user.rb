class NiceUser
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name,                      :type => String
  field :email,                     :type => String
  field :phone,                     :type => String
  field :token ,                    :type => String 
  field :platform,                  :type => String 
  field :friends_list ,             :type => Array 
  field :token ,                    :type => String 
  field :url  ,                     :type => String 
  field :uid,                       :type => String 
  field :avatar,                    :type => String 
  field :version_code ,             :type => String
  field :sdk_version  ,             :type => String 
  field :device_id  ,              :type => String 



 def as_json(options={}){
     
     :_id => id.to_s,
     :name => name ,
     :email => email,
     :phone => phone,
     :token => token,
     :platform => platform,
     :friends_list => friends_list,
     :token => token,
     :url  => url ,
     :uid => uid,
     :avatar => avatar,
     :version_code => version_code,
     :sdk_version => sdk_version,
     :device_id => device_id	


  }
  end 

end

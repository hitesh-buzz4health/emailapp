class Campaign
  include Mongoid::Document
  include Mongoid::Timestamps



  field :name, 			    :type => String 
  field :time,              :type =>  String
  field :total_no_of_mails, :type => String 

  has_many :third_party_visitors, :class_name =>'ThirdPartyVisitor' 

 
 end 

class Campaign
  include Mongoid::Document
  include Mongoid::Timestamps



  field :name, 			 :type => String 
  belongs_to :customer,  :class_name => 'Customer'
  has_many :third_party_visitors, :class_name =>'ThirdPartyVisitor' 

  has_and_belongs_to_many :participants, :class_name =>'User'
 
 end 

class ThirdPartyVisitor
  include Mongoid::Document
  include Mongoid::Timestamps



  field :visitor_id, 		:type => String 
  field :count ,			:type => Integer, :default => 1
  field :page_name ,	    :type => String
  field :country_code ,	    :type => String

  has_many  :campaign,  :class_name => 'Campaign'

 end 

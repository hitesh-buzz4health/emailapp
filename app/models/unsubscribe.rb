class Unsubscribe
  include Mongoid::Document
  include Mongoid::Timestamps

  field :email, :type => String
  field :reason, :type => String
  validates_presence_of     :email
end

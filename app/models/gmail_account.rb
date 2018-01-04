class GmailAccount
  include Mongoid::Document
  include Mongoid::Timestamps 

  field :email,                      :type => String,  :default => ''
  field :pass,                       :type => String
  field :status,                     :type => String, :default => 'unused' # {inuse, used} 
  field :activity_at,                :type => Time
  field :first_name,                 :type => String, :default => 'Sheerin'
  field :total_emails_sent,          :type => Integer, :default => 0

end
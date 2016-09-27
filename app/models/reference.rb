class Reference
  include Mongoid::Document
  include Mongoid::Timestamps


  field                     :emails,      :type => Array,  :default => []
  field                     :phones,      :type => Array,  :default => []
  field                     :ReferenceSpecialization,      :type => String, :default => ""
  field                     :ReferenceName,      :type => String, :default => ""
  field                     :ReferenceEmail,      :type => String, :default => ""
  field                     :ReferenceId,      :type => String, :default => ""
  field                     :Name,      :type => String, :default => ""
  field                     :IsRefDoctor,      :type => String, :default => ""

 field :unique_key, type: String, :default => ""


  validates_uniqueness_of :unique_key

  paginates_per 10000



end

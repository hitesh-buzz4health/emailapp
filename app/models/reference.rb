class Reference
  include Mongoid::Document
  include Mongoid::Timestamps
   include Mongoid::FullTextSearch


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
  fulltext_search_in :Name, :index_name => 'name_index'
  fulltext_search_in :ReferenceEmail,  :index_name => 'ref_email_index'
  fulltext_search_in :ReferenceName,  :index_name => 'ref_name_index'
  fulltext_search_in :ReferenceSpecialization,  :index_name => 'ref_spec_index' 


end

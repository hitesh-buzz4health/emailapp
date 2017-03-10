class Reference
  include Mongoid::Document
  include Mongoid::Timestamps
   include Mongoid::FullTextSearch


  field                     :Emails,      :type => Array,  :default => []
  field                     :Phones,      :type => Array,  :default => []
  field                     :ReferenceSpecialization,      :type => String, :default => ""
  field                     :ReferenceName,      :type => String, :default => ""
  field                     :ReferenceEmail,      :type => String, :default => ""
  field                     :ReferenceId,      :type => String, :default => ""
  field                     :Name,              :type => String, :default => ""
  field                     :isRefDoctor,      :type => String, :default => ""
  field                     :PinCode ,          :type => String, :default => ""
  field                     :Specialization  , :type => String , :default => ""
  field                     :Address        ,   :type => String , :default => ""
  

 field :unique_key, type: String, :default => ""


  validates_uniqueness_of :unique_key

  paginates_per 10000
  fulltext_search_in :Name, :index_name => 'name_index'
  fulltext_search_in :ReferenceEmail,  :index_name => 'ref_email_index'
  fulltext_search_in :ReferenceName,  :index_name => 'ref_name_index'
  fulltext_search_in :ReferenceSpecialization,  :index_name => 'ref_spec_index' 
  # index({ReferenceName: 1, Name: 1}, {unique: true, drop_dups: true, name: 'unique_refname'})

end

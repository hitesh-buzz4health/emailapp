class ReferenceJustdial
  include Mongoid::Document
  include Mongoid::Timestamps
   include Mongoid::FullTextSearch


  field                     :Emails,      :type => Array,  :default => []
  field                     :Phones,      :type => Array,  :default => []
  field                     :ReferenceName,      :type => String, :default => ""
  field                     :Name,              :type => String, :default => ""
  field                     :PinCode ,          :type => String, :default => ""
  field                     :Specialization  , :type => String , :default => ""
  field                     :Address        ,   :type => String , :default => ""
  field                     :ClinicName     ,   :type => String  , :default => ""
  field                     :City           ,   :type => String   , :default => ""
  field                     :State          ,    :type => String   , :default => ""
  field                     :ProfileLink    ,    :type => String  ,  :default => ""
  

  paginates_per 10000
  fulltext_search_in :Name, :index_name => 'name_index'
  fulltext_search_in :ReferenceName,  :index_name => 'ref_name_index'

  def name
    return self.Name
  end

end

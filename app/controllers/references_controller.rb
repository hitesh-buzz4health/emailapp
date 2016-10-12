class ReferencesController < ApplicationController


def index

@references = Reference.all
end

def filter_by_reference_name
@references = Reference.where(:ReferenceName => params[:ref_name]).where(:emails => {"$exists" => true}, :emails.not => {"$size" => 0})

    respond_to do |format|
        format.js
    end


end

def filter_by_reference_specialization

	@references = Reference.where(:ReferenceSpecialization => params[:ref_spec]).where(:emails => {"$exists" => true}, :emails.not => {"$size" => 0})

    respond_to do |format|
        format.js
    end


end

def filter_by_reference_email


	@references = Reference.where(:ReferenceEmail => params[:ref_email]).where(:emails => {"$exists" => true}, :emails.not => {"$size" => 0})

    respond_to do |format|
        format.js
    end


end

def filter_by_reference_type
#doctor or not
    isref = false
    if params[:ref_type] == "doctor"
	 isref = true
	end
	@references = Reference.where(:IsRefDoctor => isref).where(:emails => {"$exists" => true}, :emails.not => {"$size" => 0})

    respond_to do |format|
        format.js
    end

end


def search

  if params[:searchbyname].eql?("true")
    @references = Reference.fulltext_search(params[:search_value], :index => 'ref_name_index')
    
  end
  if params[:searchbyemail].eql?("true")
        @references = Reference.fulltext_search(params[:search_value], :index => 'ref_email_index')
      
  end
    respond_to do |format|
        format.js
    end

end


end

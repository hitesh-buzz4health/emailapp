class History
  include Mongoid::Document

  include Mongoid::Timestamps

  field :list, type: Hash
  field :name, type: String
  field :subject, type: String
  field :cta, type: String
  field :count, type: Integer
end

class Taxon < ActiveRecord::Base
  belongs_to :taxon_family

  default_scope :order => 'position ASC'
end

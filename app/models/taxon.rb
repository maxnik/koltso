class Taxon < ActiveRecord::Base
  belongs_to :taxon_family
  has_many :taxonomies

  default_scope :order => 'position ASC'
end

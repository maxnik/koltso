class Taxonomy < ActiveRecord::Base
  belongs_to :resource, :polymorphic => true
  belongs_to :taxon
end

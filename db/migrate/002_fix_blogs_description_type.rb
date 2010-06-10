class FixBlogsDescriptionType < ActiveRecord::Migration
  def self.up
     change_column(:blogs, :description, :text, :default => nil)
  end

  def self.down
  end
end

class Player < ActiveRecord::Base
  attr_accessible :id, :email, :losses, :name, :rating, :wins
  validates :email, :email_format => {:message => 'invalid e-mail format'}
  validates :name, :email, :presence => true
  validates_uniqueness_of :id, :scope => :id
  validates_uniqueness_of :email, :scope => :email
end

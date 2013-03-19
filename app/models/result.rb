class Result < ActiveRecord::Base
  attr_accessible :away_rating, :away_score, :home_rating, :home_score, :home_player, :away_player, :home_player_id, :away_player_id
  belongs_to :home_player, :class_name => 'Player'
  belongs_to :away_player, :class_name => 'Player'

  validates :home_player_id, :away_player, :presence => true
  validates :away_player_id, :uniqueness => { :scope => :home_player_id, :message => "can't play against yourself" }
  validates :home_score, :away_score, :presence => true, :numericality => { :only_integer => true }
  validate :only_one_winner

  def only_one_winner
    if self.home_score > self.away_score
      if self.home_score != 11
        errors.add("winners score should equal 11")
      end
    end
    if self.away_score > self.home_score
      if self.away_score != 11
        errors.add("winners score should equal 11")
      end
    end
  end
end

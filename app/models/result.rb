class Result < ActiveRecord::Base
  attr_accessible :away_rating, :away_score, :home_rating, :home_score, :home_player, :away_player, :home_player_id, :away_player_id, :rating_change, :type
  belongs_to :home_player, :class_name => 'Player'
  belongs_to :away_player, :class_name => 'Player'

  validates :home_player_id, :away_player_id, :presence => true
  validates :home_score, :away_score, :presence => true, :numericality => { :greater_than_or_equal_to => 0, :only_integer => true }
  validate :play_against_yourself

  def play_against_yourself
    logger.info("Testing play against yourself, home: "+home_player_id.to_s+" away: "+away_player_id.to_s)
    if (home_player_id == away_player_id)
      logger.info("Tested away player equals home player")
      errors.add(:unique_player, " error: you cannot play against yourself!")
    end
    logger.info("Tested play against yourself")
  end

end

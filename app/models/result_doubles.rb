class ResultDoubles < Result
  attr_accessible :home_partner_id, :away_partner_id, :home_partner_rating, :away_partner_rating, :home_partner, :away_partner
  belongs_to :home_partner, :class_name => 'Player'
  belongs_to :away_partner, :class_name => 'Player'

  validates :home_partner_id, :away_partner_id, :presence => true
  validate :all_unique_players

  def all_unique_players
    logger.info("Testing all unique players, home: "+home_player_id.to_s+", "+home_partner_id.to_s+", away: "+away_player_id.to_s+", "+away_partner_id.to_s)
    if (home_player_id == away_player_id || home_player_id == home_partner_id || home_player_id == away_partner_id || away_player_id == home_partner_id || away_player_id == away_partner_id || home_partner_id == away_partner_id)
      logger.info("At least one player equaled at least one other player")
      errors.add(:unique_player, " error: you cannot have the same player in more than one slot in a doubles match!")
    end
    logger.info("Tested all_unique_players")
  end
end

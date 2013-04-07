class ResultsController < ApplicationController
  # GET /results
  # GET /results.json
  def index
    @results = Result.find(:all, :conditions => [ "type is NULL"])
    @results.sort_by {|result| result.created_at}.reverse!
    @dresults = ResultDoubles.all
    @dresults.sort_by {|result| result.created_at}.reverse!
    # used this at first to make sure all results were calculated when it showed the index, but not a problem now
    # for result in @results
    #   calculate_ratings(result)
    # end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @results }
    end
  end

  # GET /results/1
  # GET /results/1.json
  def show
    @result = Result.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @result }
    end
  end

  # GET /results/new
  # GET /results/new.json
  def new
    @result = Result.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @result }
    end
  end

  # GET /results/1/edit
  def edit
    @result = Result.find(params[:id])
  end

  # POST /results
  # POST /results.json
  def create
    @result = nil
    if (params.has_key?(:result) && params[:result][:type] == "ResultDoubles")
      @result = ResultDoubles.new(params[:result])
    else
      @result = Result.new(params[:result])
    end

    respond_to do |format|
      if @result.save
        calculate_ratings(@result)
        format.html { redirect_to :controller => "home", :action => "index", notice: 'Result was successfully created.' }
        format.json { render json: @result, status: :created, location: @result }
      else
        format.html { render action: "new" }
        format.json { render json: @result.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /results/1
  # PUT /results/1.json
  def update
    @result = Result.find(params[:id])

    respond_to do |format|
      if @result.update_attributes(params[:result])
        format.html { redirect_to @result, notice: 'Result was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /results/1
  # DELETE /results/1.json
  def destroy
    @result = Result.find(params[:id])
    logger.info "deleting result "+@result.inspect
    unless @result[:home_rating].blank?
      if @result[:home_score] < @result[:away_score]
        winner = Player.find(@result[:away_player_id])
        loser = Player.find(@result[:home_player_id])
        if @result.is_a? ResultDoubles
          winner_partner = Player.find(@result[:away_partner_id])
          loser_partner = Player.find(@result[:home_partner_id])
        end
      else
	winner = Player.find(@result[:home_player_id])
        loser = Player.find(@result[:away_player_id])
        if @result.is_a? ResultDoubles
          winner_partner = Player.find(@result[:home_partner_id])
          loser_partner = Player.find(@result[:away_partner_id])
        end
      end
      winner[:wins] -= 1
      loser[:losses] -= 1
      ch = @result[:rating_change]
      winner[:rating] -= ch
      loser[:rating] += ch
      if @result.is_a? ResultDoubles
        winner_partner[:wins] -= 1
        loser_partner[:losses] -= 1
        winner_partner[:rating] -= ch
        loser_partner[:rating] += ch
        winner_partner.save
	loser_partner.save
      end
      winner.save
      loser.save
    end
    @result.destroy

    respond_to do |format|
      format.html { redirect_to results_url }
      format.json { head :no_content }
    end
  end

  def calculate_ratings( result )
    logger.info "calculate_ratings called with " + result.inspect
    if (result.is_a? ResultDoubles)
      calculate_doubles_rating( result )
    else
      calculate_singles_rating( result )
    end
  end

  def calculate_singles_rating( result )
    logger.info "calculating a singles rating"
    if result[:home_score] < result[:away_score]
      winner = Player.find(result[:away_player_id])
      loser = Player.find(result[:home_player_id])
    else
      winner = Player.find(result[:home_player_id])
      loser = Player.find(result[:away_player_id])
    end
    result[:home_rating] = winner.rating
    result[:away_rating] = loser.rating
    winner[:wins] += 1
    loser[:losses] += 1
    ch = calculate_change(winner[:rating],loser[:rating])
    winner[:rating] += ch
    loser[:rating] -= ch
    result[:rating_change] = ch
    result.save
    winner.save
    loser.save
  end

  def calculate_doubles_rating( result )
    logger.info "calculating a doubles rating"
    if result[:home_score] < result[:away_score]
      winner = Player.find(result[:away_player_id])
      loser = Player.find(result[:home_player_id])
      winner_partner = Player.find(result[:away_partner_id])
      loser_partner = Player.find(result[:home_partner_id])
    else
      winner = Player.find(result[:home_player_id])
      loser = Player.find(result[:away_player_id])
      winner_partner = Player.find(result[:home_partner_id])
      loser_partner = Player.find(result[:away_partner_id])
    end
    result[:home_rating] = winner.rating
    result[:away_rating] = loser.rating
    result[:home_partner_rating] = winner_partner.rating
    result[:away_partner_rating] = loser_partner.rating
    winner[:wins] += 1
    winner_partner[:wins] += 1
    loser[:losses] += 1
    loser_partner[:losses] += 1
    winning_team_rating = (winner[:rating] + winner_partner[:rating]) / 2
    losing_team_rating = (loser[:rating] + loser_partner[:rating]) / 2
    ch = calculate_change(winning_team_rating,losing_team_rating)
    winner[:rating] += ch
    winner_partner[:rating] += ch
    loser[:rating] -= ch
    loser_partner[:rating] -= ch
    result[:rating_change] = ch
    result.save
    winner.save
    winner_partner.save
    loser.save
    loser_partner.save
  end

  def calculate_change (winner_rating, loser_rating)
    logger.info "winner-rating = " + winner_rating.to_s
    logger.info "loser-rating = " + loser_rating.to_s
    ws = winner_rating - loser_rating
    ls = ws / 400.0
    rs = 10 ** ls
    logger.info "ws = " + ws.to_s + ", ls = " + ls.to_s + ", rs = " + rs.to_s
    es = (1/(1+rs)).abs.to_f
    logger.info "es = " + es.to_s
    ch = (es * 50).to_i
    logger.info "ch = " + ch.to_s
    return ch
  end
end

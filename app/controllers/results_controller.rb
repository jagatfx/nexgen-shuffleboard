class ResultsController < ApplicationController
  # GET /results
  # GET /results.json
  def index
    @results = Result.all
    @results.sort_by {|result| result.created_at}.reverse!
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
    if (params[:result][:type] == "ResultDoubles")
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
      winner = Player.find(@result[:home_player_id])
      loser = Player.find(@result[:away_player_id])
      @result[:home_player] = winner
      @result[:away_player] = loser
      @result[:home_rating] = winner.rating
      @result[:away_rating] = loser.rating
      if @result[:home_score] < @result[:away_score]
        winner = Player.find(@result[:away_player_id])
        loser = Player.find(@result[:home_player_id])
      end
      winner[:wins] -= 1
      loser[:losses] -= 1
      ch = @result[:rating_change]
      winner[:rating] -= ch
      loser[:rating] += ch
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
    winner = Player.find(result[:home_player_id])
    loser = Player.find(result[:away_player_id])
    result[:home_player] = winner
    result[:away_player] = loser
    result[:home_rating] = winner.rating
    result[:away_rating] = loser.rating
    if result[:home_score] < result[:away_score]
      winner = Player.find(result[:away_player_id])
      loser = Player.find(result[:home_player_id])
      result[:away_player] = winner
      result[:home_player] = loser
    end
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

class HomeController < ApplicationController
  def index
    @players = Player.find(:all, :order => 'rating').reverse
  end
end

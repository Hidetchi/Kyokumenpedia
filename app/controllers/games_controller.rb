class GamesController < ApplicationController
  protect_from_forgery :except => 'create'

  def create
    response = Game.save_after_validation(params, true)
    response[:result] = "Error: " + response[:result] unless (response[:result] == 'Success')
    render :xml => response.to_xml(:root => 'api_response')
  end
end

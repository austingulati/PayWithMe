class CardsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :json

  def create
    params[:card] ||= {}
    card = Card.new(params[:card].slice(:brand, :expiration_month, :expiration_year, :uri))
    if current_user.account.present?
      logger.debug "Associated card for existing account for user #{current_user.id}"
      current_user.account.associate_card(card)
    else
      # Creating a new account and immeadiately associating the card
      account = Account.new_from_card(card, current_user)
      if account.valid?
        # Success state, the account has just been created
        logger.debug "Created account and card for user #{current_user.id}"
        current_user.account = account
        current_user.account.cards << card
        current_user.account.save
      else
        # Show an error response, card creation failed
      end
    end

    respond_with(card) do |format|
      format.js {render json: card, root: "card"}
    end
  end

  def show
    respond_with_not_found
  end

  def index
    respond_with_not_found
  end

  def delete
    respond_with_not_found
  end

  def update
    respond_with_not_found
  end

end
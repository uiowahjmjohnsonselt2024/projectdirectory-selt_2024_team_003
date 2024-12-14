class CreditCardsController < ApplicationController
    def redirect_to_card
      if current_user.credit_card
        redirect_to credit_card_path # Show action
      else
        redirect_to new_credit_card_path # New action
      end
    end

    def new
      @credit_card = CreditCard.new
    end
  
    def create
      @credit_card = current_user.build_credit_card(credit_card_params)
      if @credit_card.save
        redirect_to credit_card_path, notice: 'Credit card added successfully.'
      else
        render :new, status: :unprocessable_entity
      end
    end
  
    def show
      @credit_card = current_user.credit_card
    end
  
    def edit
      @credit_card = CreditCard.new # Require re-entry of the full card number
    end
  
    def update
      if current_user.credit_card
        current_user.credit_card.destroy # Replace the existing card if one exists
      end

      @credit_card = current_user.build_credit_card(credit_card_params)
      if @credit_card.save
        redirect_to credit_card_path, notice: 'Credit card updated successfully.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private
  
    def credit_card_params
      params.require(:credit_card).permit(:card_number, :cvv, :expiration_month, :expiration_year)
    end
end

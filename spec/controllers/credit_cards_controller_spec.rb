require 'rails_helper'

RSpec.describe CreditCardsController, type: :controller do
  let(:mock_user) { instance_double(User, id: 1, credit_card: mock_credit_card, build_credit_card: mock_credit_card) }
  let(:mock_credit_card) { instance_double(CreditCard, save: true, destroy: true) }
  let(:valid_attributes) do
    {
      "card_number" => '4111111111111111',
      "cvv" => '123',
      "expiration_month" => '12',
      "expiration_year" => '2030'
    }
  end
  let(:invalid_attributes) { { "card_number" => nil, "cvv" => nil, "expiration_month" => nil, "expiration_year" => nil } }

  before do
    allow(controller).to receive(:current_user).and_return(mock_user)
  end

  describe "GET #redirect_to_card" do
    context "when user has a credit card" do
      before { allow(mock_user).to receive(:credit_card).and_return(mock_credit_card) }

      it "redirects to the show action" do
        get :redirect_to_card
        expect(response).to redirect_to(credit_card_path)
      end
    end

    context "when user does not have a credit card" do
      before { allow(mock_user).to receive(:credit_card).and_return(nil) }

      it "redirects to the new action" do
        get :redirect_to_card
        expect(response).to redirect_to(new_credit_card_path)
      end
    end
  end

  describe "GET #new" do
    it "assigns a new credit card" do
      get :new
      expect(assigns(:credit_card)).to be_a_new(CreditCard)
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      before { allow(mock_credit_card).to receive(:save).and_return(true) }

      it "creates a new credit card and redirects to the show action" do
        post :create, params: { credit_card: valid_attributes }
        expect(response).to redirect_to(credit_card_path)
        expect(flash[:notice]).to eq('Credit card added successfully.')
      end
    end

    context "with invalid parameters" do
      before { allow(mock_credit_card).to receive(:save).and_return(false) }

      it "renders the new template with unprocessable_entity status" do
        post :create, params: { credit_card: invalid_attributes }
        expect(response).to render_template(:new)
        expect(response.status).to eq(422)
      end
    end
  end

  describe "GET #show" do
    it "assigns the current user's credit card" do
      get :show
      expect(assigns(:credit_card)).to eq(mock_credit_card)
    end
  end

  describe "GET #edit" do
    it "assigns a new credit card instance for editing" do
      get :edit
      expect(assigns(:credit_card)).to be_a_new(CreditCard)
    end
  end

  describe "PATCH/PUT #update" do
    context "when user already has a credit card" do
      before { allow(mock_user).to receive(:credit_card).and_return(mock_credit_card) }

      it "destroys the existing credit card and replaces it" do
        expect(mock_credit_card).to receive(:destroy)
        patch :update, params: { credit_card: valid_attributes }
      end

      context "with valid parameters" do
        before { allow(mock_credit_card).to receive(:save).and_return(true) }

        it "updates the credit card and redirects to the show action" do
          patch :update, params: { credit_card: valid_attributes }
          expect(response).to redirect_to(credit_card_path)
          expect(flash[:notice]).to eq('Credit card updated successfully.')
        end
      end

      context "with invalid parameters" do
        before { allow(mock_credit_card).to receive(:save).and_return(false) }

        it "renders the edit template with unprocessable_entity status" do
          patch :update, params: { credit_card: invalid_attributes }
          expect(response).to render_template(:edit)
          expect(response.status).to eq(422)
        end
      end
    end

    context "when user does not have a credit card" do
      before { allow(mock_user).to receive(:credit_card).and_return(nil) }

      it "creates a new credit card" do
        expect(mock_user).to receive(:build_credit_card).with(ActionController::Parameters.new(valid_attributes).permit!).and_return(mock_credit_card)
        patch :update, params: { credit_card: valid_attributes }
      end
    end
  end

  private

  def credit_card_path
    "/credit_card"
  end

  def new_credit_card_path
    "/credit_card/new"
  end
end

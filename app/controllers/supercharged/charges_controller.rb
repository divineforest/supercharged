class Supercharged::ChargesController < ApplicationController

  def new
  end

  def create
    charge = Charge.new(charge_params)
    charge.user = current_user

    if charge.save
      render json: charge.as_json(only: [:id])
    else
      render json: { errors: charge.errors }, status: :unprocessable_entity
    end
  end

  # For example for PayPal Express, which requires getting token before purchase action.
  def setup_purchase
    charge = Charge.find(params[:charge_id])

    token = charge.setup_purchase(
      ip: request.remote_ip,
      return_url: complete_charges_url,
      cancel_return_url: new_charge_url
    )

    redirect_to charge.gateway.redirect_url_for(token)
  end

  def complete
    params.require(:token)

    @charge = Charge.with_token(params[:token])

    if @charge
      @charge.complete(params)

      redirect_to root_url
    else
      head :not_found
    end
  end

  private

  def charge_params
    params.require(:charge).permit(:amount, :gateway_name)
  end

end

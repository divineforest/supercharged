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

  private

  def charge_params
    params.require(:charge).permit(:amount)
  end

end

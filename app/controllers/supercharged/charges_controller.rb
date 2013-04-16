class Supercharged::ChargesController < ApplicationController

  def new
  end

  def create
    @charge = Charge.new(charge_params)
    @charge.user = current_user
    @charge.save!
    render json: @charge.as_json(only: [:id])
  end

  private

  def charge_params
    params.require(:charge).permit(:amount)
  end

end

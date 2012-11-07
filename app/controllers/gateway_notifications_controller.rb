class GatewayNotificationsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def create
    @notification = GatewayInputNotification.create!(params: params, gateway: params[:gateway], raw_post: request.raw_post)

    error = if !@notification.complete?
      "not_completed"
    elsif !@notification.acknowledge
      "acknowledge_failed"
    end

    if error
      @notification.charge.failed!
      @notification.charge.update_attribute(:error, error)
      head :bad_request
    else
      # success
      @notification.charge.approve unless @notification.charge.ok?
      if @notification.need_response?
        render text: @notification.success_response
      else
        redirect_to root_url
      end
    end
  end

  def success
    redirect_to root_url, notice: "Success"
  end

  def fail
    redirect_to root_url, error: "Fail"
  end

end

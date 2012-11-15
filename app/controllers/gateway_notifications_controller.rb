class GatewayNotificationsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def create
    @notification = GatewayInputNotification.create!(params: params, gateway: params[:gateway], raw_post: request.raw_post)

    error = if !@notification.complete?
      "not_completed"
    elsif !@notification.acknowledge
      "acknowledge_failed"
    elsif !@notification.charge
      "charge not found"
    end

    if error
      logger.error("Error: #{error.inspect}")
      if @notification.charge
        @notification.charge.failed!
        @notification.charge.update_attribute(:error, error)
      end
      head :bad_request
    else
      logger.info("Success")
      @notification.charge.approve unless @notification.charge.ok?
      if @notification.need_response?
        logger.info("Need need_response: #{@notification.success_response.inspect}")
        render text: @notification.success_response
      else
        logger.info("Redirecting")
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

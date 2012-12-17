class Supercharged::GatewayNotificationsController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def create
    logger.info("Notification for #{params[:gateway]}")
    logger.info("params = #{params.inspect}")

    @notification = GatewayNotification.create!(params: params, gateway: params[:gateway], raw_post: request.raw_post)
    @notification.logger = logger

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
      @notification.approve
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

  private

  def logger
    Logger.new("log/gateway_notifications.log")
  end

end

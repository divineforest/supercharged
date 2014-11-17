class Supercharged::GatewayNotificationsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :check_any_params, only: :create

  def create
    persistent_logger.info("Notification for #{params[:gateway]}")
    persistent_logger.info("params = #{params.inspect}")

    @notification = GatewayNotification.create!(params: params, gateway: params[:gateway], raw_post: request.raw_post)
    @notification.logger = persistent_logger

    error = if !@notification.acknowledge
      "acknowledge_failed"
    elsif !@notification.complete?
      "not_completed"
    elsif !@notification.charge
      "charge_not_found"
    end

    if error
      persistent_logger.error("Error: #{error.inspect}")

      charge = @notification.charge

      if charge && !charge.error?
        @notification.charge.fail
        @notification.charge.update_attribute(:error, error)
      end

      if @notification.need_error_response?
        persistent_logger.info("Need error response: #{@notification.error_response.inspect}")
        render text: @notification.error_response
      else
        persistent_logger.info("Redirecting")
        redirect_to new_charge_url, alert: "#{I18n.t("supercharged.gateway_controller.error.failed")}: #{I18n.t("supercharged.gateway_controller.error.#{error}")}"
      end
    else
      persistent_logger.info("Success")
      @notification.approve
      if @notification.need_success_response?
        persistent_logger.info("Need success response: #{@notification.success_response.inspect}")
        render text: @notification.success_response
      else
        persistent_logger.info("Redirecting")
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

  def persistent_logger
    @persistent_logger ||= Logger.new("log/supercharged/gateway_notifications.log")
  end

  def check_any_params
    if request.raw_post.blank?
      head :bad_request
      false
    end
  end

end

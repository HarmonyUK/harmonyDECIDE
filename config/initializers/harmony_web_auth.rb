# frozen_string_literal: true

# Load the HarmonyAuth module
require_relative '../../lib/harmony_auth'

Rails.application.config.to_prepare do
  # Include HarmonyAuth in SessionsController to handle harmony_session authentication
  Decidim::Devise::SessionsController.class_eval do
    include HarmonyAuth

    # Check for harmony_session cookie and authenticate user when they return from harmonyWEB
    before_action :authenticate_from_harmony_web, only: [:new]

    private

    def authenticate_from_harmony_web
      Rails.logger.info("HarmonyAuth: authenticate_from_harmony_web called")
      Rails.logger.info("HarmonyAuth: user_signed_in? = #{user_signed_in?}")
      Rails.logger.info("HarmonyAuth: current_organization.host = #{current_organization&.host}")

      # Skip if user is already signed in
      if user_signed_in?
        Rails.logger.info("HarmonyAuth: User already signed in, skipping")
        return
      end

      # Skip if not HarmonyUK organization
      unless current_organization&.host == 'decide.harmonyuk.org'
        Rails.logger.info("HarmonyAuth: Not HarmonyUK org, skipping")
        return
      end

      # Check if harmony_session cookie exists and is valid
      Rails.logger.info("HarmonyAuth: Checking if harmony_authenticated?")
      if harmony_authenticated?
        Rails.logger.info("HarmonyAuth: User has valid harmony_session, attempting authentication")
        user = authenticate_from_harmony_session

        if user
          # User successfully authenticated from harmonyWEB session
          # Redirect to the intended page or root
          Rails.logger.info("HarmonyAuth: Successfully authenticated user #{user.email}, redirecting to root")
          redirect_to decidim.root_path and return
        else
          Rails.logger.warn("HarmonyAuth: Failed to authenticate user from harmony_session")
        end
      else
        Rails.logger.info("HarmonyAuth: No valid harmony_session found")
      end
    end
  end

  # Also add harmony_session authentication to ApplicationController for seamless SSO
  # This ensures users are automatically logged in when visiting any page with a valid harmony_session
  Decidim::ApplicationController.class_eval do
    include HarmonyAuth

    before_action :auto_authenticate_from_harmony_web

    private

    def auto_authenticate_from_harmony_web
      Rails.logger.debug("HarmonyAuth: auto_authenticate_from_harmony_web called on #{controller_name}##{action_name}")

      # Skip if not HarmonyUK organization
      return unless current_organization&.host == 'decide.harmonyuk.org'

      # If user is already signed in, refresh their session if harmony_session is still valid
      if user_signed_in?
        # Refresh Decidim session timestamp if harmony_session is still valid
        if harmony_authenticated?
          Rails.logger.debug("HarmonyAuth: Refreshing session for logged-in user")
          # Reset Devise timeout by touching the session
          request.env['warden'].set_user(current_user, scope: :user, store: true, run_callbacks: false)
        end
        return
      end

      # Check if harmony_session cookie exists and is valid for new login
      if harmony_authenticated?
        Rails.logger.info("HarmonyAuth: Auto-authenticating user from harmony_session")
        authenticate_from_harmony_session
      end
    end
  end
end

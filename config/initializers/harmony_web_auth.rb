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
      # Skip if user is already signed in
      return if user_signed_in?

      # Skip if not HarmonyUK organization
      return unless current_organization.host == 'decide.harmonyuk.org'

      # Check if harmony_session cookie exists and is valid
      if harmony_authenticated?
        user = authenticate_from_harmony_session

        if user
          # User successfully authenticated from harmonyWEB session
          # Redirect to the intended page or root
          redirect_to decidim.root_path and return
        else
          Rails.logger.warn("HarmonyAuth: Failed to authenticate user from harmony_session")
        end
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
      # Skip if user is already signed in
      return if user_signed_in?

      # Skip if not HarmonyUK organization
      return unless current_organization&.host == 'decide.harmonyuk.org'

      # Check if harmony_session cookie exists and is valid
      if harmony_authenticated?
        authenticate_from_harmony_session
      end
    end
  end
end

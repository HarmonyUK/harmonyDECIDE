# frozen_string_literal: true

# HarmonyAuth module provides authentication integration with harmonyWEB
# by validating the harmony_session cookie and retrieving user data from Redis
module HarmonyAuth
  extend ActiveSupport::Concern

  # Check if the user is authenticated via harmonyWEB session
  # @return [Hash, nil] User data from Redis session, or nil if not authenticated
  def harmony_session_data
    return nil unless harmony_session_id.present?

    begin
      redis = Rails.cache.redis
      session_key = "harmony:session:#{harmony_session_id}"
      session_json = redis.get(session_key)

      return nil unless session_json.present?

      JSON.parse(session_json)
    rescue Redis::BaseError => e
      Rails.logger.error("HarmonyAuth Redis error: #{e.message}")
      nil
    rescue JSON::ParserError => e
      Rails.logger.error("HarmonyAuth JSON parse error: #{e.message}")
      nil
    end
  end

  # Check if user is authenticated via harmonyWEB
  # @return [Boolean]
  def harmony_authenticated?
    harmony_session_data.present?
  end

  # Authenticate user in Decidim using harmonyWEB session data
  # Creates or updates the user if necessary
  # @return [Decidim::User, nil] The authenticated user or nil
  def authenticate_from_harmony_session
    session_data = harmony_session_data
    return nil unless session_data

    email = session_data['email']
    username = session_data['username']
    user_id = session_data['user_id']

    return nil unless email.present?

    # Find or create the user in Decidim
    user = find_or_create_harmony_user(
      email: email,
      username: username,
      keycloak_id: user_id
    )

    if user
      # Sign in the user using Devise
      sign_in(:user, user)
      Rails.logger.info("HarmonyAuth: User #{email} authenticated via harmony_session")
    end

    user
  end

  private

  # Get the harmony_session cookie value
  # @return [String, nil]
  def harmony_session_id
    cookies['harmony_session']
  end

  # Find or create a user from harmonyWEB session data
  # @param email [String] User's email address
  # @param username [String] User's username
  # @param keycloak_id [String] Keycloak user UUID
  # @return [Decidim::User, nil]
  def find_or_create_harmony_user(email:, username:, keycloak_id:)
    # Try to find user by email in current organization
    user = Decidim::User.find_by(
      email: email,
      organization: current_organization
    )

    if user
      # Update Keycloak ID if not set
      if keycloak_id.present? && user.respond_to?(:oauth_uid) && user.oauth_uid.blank?
        user.update(oauth_uid: keycloak_id)
      end
      return user
    end

    # Create new user if not found
    create_harmony_user(email: email, username: username, keycloak_id: keycloak_id)
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("HarmonyAuth: Failed to create user: #{e.message}")
    nil
  end

  # Create a new Decidim user from harmonyWEB session data
  # @param email [String]
  # @param username [String]
  # @param keycloak_id [String]
  # @return [Decidim::User]
  def create_harmony_user(email:, username:, keycloak_id:)
    # Generate a unique nickname from username or email
    base_nickname = username&.split('@')&.first || email.split('@').first
    nickname = generate_unique_nickname(base_nickname)

    # Generate a secure random password (user won't use it, only OAuth login)
    password = Devise.friendly_token(20)

    Decidim::User.create!(
      email: email,
      name: username || email.split('@').first,
      nickname: nickname,
      organization: current_organization,
      password: password,
      password_confirmation: password,
      confirmed_at: Time.current, # Auto-confirm since harmonyWEB already authenticated
      accepted_tos_version: current_organization.tos_version,
      locale: current_organization.default_locale,
      oauth_uid: keycloak_id,
      oauth_provider: 'keycloakopenid'
    )
  end

  # Generate a unique nickname for the organization
  # @param base [String] Base nickname to start from
  # @return [String] Unique nickname
  def generate_unique_nickname(base)
    base = base.parameterize.underscore
    nickname = base
    counter = 1

    while Decidim::User.exists?(nickname: nickname, organization: current_organization)
      nickname = "#{base}_#{counter}"
      counter += 1
    end

    nickname
  end
end

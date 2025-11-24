# frozen_string_literal: true
# Quick test script for HarmonyAuth debugging
# Run with: rails runner lib/test_harmony_auth.rb SESSION_ID

puts "=" * 80
puts "HarmonyAuth Debug Test"
puts "=" * 80

# Get session ID from command line or use a placeholder
session_id = ARGV[0] || "REPLACE_WITH_ACTUAL_SESSION_ID"

puts "\n1. Testing Redis Connection..."
begin
  require_relative 'harmony_auth'
  redis = HarmonyAuth.redis_connection
  ping = redis.ping
  puts "   ✅ Redis connected: #{ping}"
  puts "   Redis URL: #{ENV['REDIS_STORE_URL'] || 'redis://localhost:6379/0'}"
rescue => e
  puts "   ❌ Redis connection failed: #{e.message}"
  puts "   Error: #{e.class}"
  puts "   Backtrace: #{e.backtrace.first(3).join("\n   ")}"
  exit 1
end

puts "\n2. Testing Session Lookup..."
session_key = "harmony:session:#{session_id}"
puts "   Looking for key: #{session_key}"

begin
  session_json = redis.get(session_key)

  if session_json.present?
    puts "   ✅ Session found in Redis!"
    puts "   Raw data length: #{session_json.length} bytes"
  else
    puts "   ❌ No session data found in Redis"
    puts "\n   Debugging: Let's check what keys exist..."

    # Try to find any harmony:session keys
    keys = redis.keys("harmony:session:*")
    if keys.any?
      puts "   Found #{keys.length} harmony session keys:"
      keys.first(5).each { |k| puts "     - #{k}" }
    else
      puts "   No harmony:session:* keys found in Redis"
    end
    exit 1
  end
rescue => e
  puts "   ❌ Redis query failed: #{e.message}"
  exit 1
end

puts "\n3. Testing JSON Parsing..."
begin
  data = JSON.parse(session_json)
  puts "   ✅ JSON parsed successfully!"
  puts "   Data keys: #{data.keys.join(', ')}"
  puts "   Email: #{data['email']}"
  puts "   Username: #{data['username']}"
  puts "   User ID: #{data['user_id']}"
rescue JSON::ParserError => e
  puts "   ❌ JSON parse failed: #{e.message}"
  puts "   Raw data: #{session_json[0..200]}"
  exit 1
end

puts "\n4. Testing User Lookup..."
begin
  org = Decidim::Organization.find_by(host: 'decide.harmonyuk.org')

  if org
    puts "   ✅ Organization found: #{org.name}"

    email = data['email']
    if email.present?
      user = Decidim::User.find_by(email: email, organization: org)

      if user
        puts "   ✅ User exists in Decidim: #{user.email} (ID: #{user.id})"
      else
        puts "   ⚠️  User does not exist yet (will be created on login)"
        puts "   Email would be: #{email}"
      end
    else
      puts "   ❌ No email in session data"
    end
  else
    puts "   ❌ Organization not found: decide.harmonyuk.org"
  end
rescue => e
  puts "   ❌ User lookup failed: #{e.message}"
  puts e.backtrace.first(5).join("\n")
end

puts "\n" + "=" * 80
puts "Test complete!"
puts "=" * 80
puts "\nTo test with an actual session ID:"
puts "  rails runner lib/test_harmony_auth.rb YOUR_SESSION_ID"
puts ""

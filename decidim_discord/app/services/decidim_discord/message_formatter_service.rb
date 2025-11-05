module DecidimDiscord
  class MessageFormatterService
    def self.format(event_type, payload)
      new(event_type, payload).call
    end

    def initialize(event_type, payload)
      @event_type = event_type
      @payload = payload
    end

    def call
      case @event_type
      when :proposal_created
        format_proposal_created
      when :proposal_status_changed
        format_proposal_status_changed
      when :amendment_created
        format_amendment_created
      when :endorsement_milestone
        format_endorsement_milestone
      else
        default_format
      end
    end

    private

    def format_proposal_created
      {
        content: nil,
        embeds: [
          {
            title: "📝 New Proposal Created",
            description: @payload[:proposal_title],
            color: 0x3498db,
            fields: [
              { name: "Assembly", value: @payload[:assembly_name], inline: true },
              { name: "Component", value: @payload[:component_name], inline: true },
              { name: "Author", value: @payload[:author_name], inline: true },
              { 
                name: "View Proposal", 
                value: "[Click here](#{@payload[:proposal_url]})", 
                inline: false 
              }
            ],
            timestamp: Time.current.iso8601,
            footer: {
              text: "Decidim Notifications"
            }
          }
        ]
      }
    end

    def format_proposal_status_changed
      status = @payload[:new_status]
      color_map = {
        "evaluating" => 0xf39c12,
        "accepted" => 0x27ae60,
        "rejected" => 0xe74c3c,
        "withdrawn" => 0x95a5a6
      }

      status_emoji = {
        "evaluating" => "🔍",
        "accepted" => "✅",
        "rejected" => "❌",
        "withdrawn" => "🚫"
      }

      {
        content: nil,
        embeds: [
          {
            title: "#{status_emoji[status] || '🔄'} Proposal Status Changed",
            description: @payload[:proposal_title],
            color: color_map[status] || 0x3498db,
            fields: [
              { name: "Assembly", value: @payload[:assembly_name], inline: true },
              { name: "Component", value: @payload[:component_name], inline: true },
              { name: "Old Status", value: @payload[:old_status], inline: true },
              { name: "New Status", value: status, inline: true },
              { 
                name: "View Proposal", 
                value: "[Click here](#{@payload[:proposal_url]})", 
                inline: false 
              }
            ],
            timestamp: Time.current.iso8601,
            footer: {
              text: "Decidim Notifications"
            }
          }
        ]
      }
    end

    def format_amendment_created
      {
        content: nil,
        embeds: [
          {
            title: "✏️ Amendment Created",
            description: @payload[:amendment_title],
            color: 0x9b59b6,
            fields: [
              { name: "Assembly", value: @payload[:assembly_name], inline: true },
              { name: "Original Proposal", value: @payload[:proposal_title], inline: true },
              { name: "Author", value: @payload[:author_name], inline: true },
              { 
                name: "View Amendment", 
                value: "[Click here](#{@payload[:amendment_url]})", 
                inline: false 
              }
            ],
            timestamp: Time.current.iso8601,
            footer: {
              text: "Decidim Notifications"
            }
          }
        ]
      }
    end

    def format_endorsement_milestone
      {
        content: nil,
        embeds: [
          {
            title: "🎯 Endorsement Milestone Reached!",
            description: @payload[:proposal_title],
            color: 0x2ecc71,
            fields: [
              { name: "Assembly", value: @payload[:assembly_name], inline: true },
              { name: "Component", value: @payload[:component_name], inline: true },
              { name: "Threshold Met", value: "#{@payload[:endorsement_count]} / #{@payload[:threshold]} votes", inline: true },
              { 
                name: "View Proposal", 
                value: "[Click here](#{@payload[:proposal_url]})", 
                inline: false 
              }
            ],
            timestamp: Time.current.iso8601,
            footer: {
              text: "Decidim Notifications"
            }
          }
        ]
      }
    end

    def default_format
      {
        content: "Event: #{@event_type}\nPayload: #{@payload.inspect}"
      }
    end
  end
end

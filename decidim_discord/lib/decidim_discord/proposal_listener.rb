module DecidimDiscord
  class ProposalListener
    def self.attach
      Decidim::Proposals::Proposal.after_create do |proposal|
        begin
          DecidimDiscord::ProposalListener.on_proposal_created(proposal)
        rescue StandardError => e
          Rails.logger.error("DecidimDiscord ProposalListener error: #{e.message}\n#{e.backtrace.join("\n")}")
        end
      end
      
      Decidim::Proposals::Proposal.after_update do |proposal|
        begin
          DecidimDiscord::ProposalListener.on_proposal_updated(proposal)
        rescue StandardError => e
          Rails.logger.error("DecidimDiscord ProposalListener error: #{e.message}\n#{e.backtrace.join("\n")}")
        end
      end
    end

    def self.on_proposal_created(proposal)
      return unless proposal.published?

      author_name = begin
        proposal.coauthorships.first&.author&.name || "Unknown Author"
      rescue StandardError
        "Unknown Author"
      end

      assembly_slug = proposal.component.participatory_space.slug
      
      payload = {
        proposal_title: proposal.title,
        proposal_url: "https://decide.harmonyuk.org/assemblies/#{assembly_slug}/f/#{proposal.component.id}/proposals/#{proposal.id}",
        assembly_name: proposal.component.participatory_space.title["en"] || proposal.component.participatory_space.title.values.first,
        component_name: proposal.component.name["en"] || proposal.component.name.values.first,
        author_name: author_name,
        created_at: proposal.created_at.iso8601
      }

      DecidimDiscord::DiscordWebhookService.notify(:proposal_created, payload)
    end

    def self.on_proposal_updated(proposal)
      return unless proposal.saved_changes.key?(:decidim_proposals_proposal_state_id)

      assembly_slug = proposal.component.participatory_space.slug
      
      payload = {
        proposal_title: proposal.title,
        proposal_url: "https://decide.harmonyuk.org/assemblies/#{assembly_slug}/f/#{proposal.component.id}/proposals/#{proposal.id}",
        assembly_name: proposal.component.participatory_space.title["en"] || proposal.component.participatory_space.title.values.first,
        component_name: proposal.component.name["en"] || proposal.component.name.values.first,
        old_status: proposal.old_state || "unknown",
        new_status: proposal.state || "unknown",
        state_updated_at: Time.current.iso8601
      }

      DecidimDiscord::DiscordWebhookService.notify(:proposal_status_changed, payload)
    end
  end
end

module DecidimDiscord
  class AmendmentListener
    def self.attach
      Decidim::Amendment.after_create { |amendment| on_amendment_created(amendment) }
    end

    def self.on_amendment_created(amendment)
      return unless amendment.published?

      proposal = amendment.amendable
      assembly_slug = proposal.component.participatory_space.slug

      payload = {
        amendment_title: amendment.title,
        amendment_url: "https://decide.harmonyuk.org/assemblies/#{assembly_slug}/f/#{proposal.component.id}/amendments/#{amendment.id}",
        proposal_title: proposal.title,
        assembly_name: proposal.component.participatory_space.title["en"] || proposal.component.participatory_space.title.values.first,
        component_name: proposal.component.name["en"] || proposal.component.name.values.first,
        author_name: amendment.coauthorships.first&.author&.name || "Unknown Author",
        created_at: amendment.created_at.iso8601
      }

      DecidimDiscord::DiscordWebhookService.notify(:amendment_created, payload)
    end
  end
end

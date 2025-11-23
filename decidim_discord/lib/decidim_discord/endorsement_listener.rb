module DecidimDiscord
  class EndorsementListener
    def self.attach
      Decidim::Proposals::ProposalVote.after_create { |vote| on_vote_created(vote) }
    end

    def self.on_vote_created(vote)
      proposal = vote.proposal
      component = proposal.component
      assembly = component.participatory_space

      threshold = component.settings.try(:votes_threshold) || component.settings.try(:endorsement_threshold)
      return unless threshold

      endorsement_count = proposal.proposal_votes_count

      return unless endorsement_count >= threshold && (endorsement_count - 1) < threshold

      assembly_slug = assembly.slug

      payload = {
        proposal_title: proposal.title,
        proposal_url: "https://decide.harmonyuk.org/assemblies/#{assembly_slug}/f/#{component.id}/proposals/#{proposal.id}",
        assembly_name: assembly.title["en"] || assembly.title.values.first,
        component_name: component.name["en"] || component.name.values.first,
        endorsement_count: endorsement_count,
        threshold: threshold,
        milestone_reached_at: Time.current.iso8601
      }

      DecidimDiscord::DiscordWebhookService.notify(:endorsement_milestone, payload)
    end
  end
end

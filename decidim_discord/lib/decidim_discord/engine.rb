module DecidimDiscord
  class Engine < ::Rails::Engine
    engine_name "decidim_discord"

    config.to_prepare do
       DecidimDiscord::ProposalListener.attach
       DecidimDiscord::AmendmentListener.attach
       DecidimDiscord::EndorsementListener.attach
    end
  end
end

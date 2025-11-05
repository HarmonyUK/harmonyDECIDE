Rails.application.config.to_prepare do
    Decidim::ImageUploader.class_eval do
        def content_type_allowlist
            %w[image/jpeg image/png image/gif image/webp]
        end
    end
end

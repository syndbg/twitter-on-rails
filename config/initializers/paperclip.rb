if Rails.env.development? || Rails.env.production?
  Paperclip::Attachment.default_options[:s3_host_name] = 's3.eu-central-1.amazonaws.com'
end

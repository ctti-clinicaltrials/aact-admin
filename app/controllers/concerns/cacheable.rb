module Cacheable
  extend ActiveSupport::Concern

  # to set different cache expiry times for different classes
  class_methods do
    attr_writer :cache_expiry # setter

    # getter with the default value
    def cache_expiry
      @cache_expiry || 10.minutes
    end
  end

  def fetch_with_cache(cache_key, expires_in: self.class.cache_expiry)
    Rails.logger.info "Checking cache for key: #{cache_key}"

    cached_data = Rails.cache.read(cache_key)
    return cached_data if cached_data

    Rails.logger.info "Cache miss for #{cache_key}, fetching fresh data"
    data = yield if block_given?

    if data.present?
      Rails.logger.info "Caching data for #{cache_key} (#{expires_in / 60} minutes)"
      Rails.cache.write(cache_key, data, expires_in: expires_in)
    else
      Rails.logger.warn "No valid data to cache for #{cache_key}"
    end

    data
  end

  # Invalidate cache for a key
  def invalidate_cache(cache_key)
    Rails.logger.info "Invalidating cache for #{cache_key}"
    Rails.cache.delete(cache_key)
  end
end
# frozen_string_literal: true

class InstancePresenter
  delegate(
    :site_contact_email,
    :site_title,
    :site_short_description,
    :site_description,
    :site_extended_description,
    :max_bio_chars,
    :max_toot_chars,
    :site_terms,
    :closed_registrations_message,
    to: Setting
  )

  def active_count(timespan: Time.zone.now - 1.month..Time.zone.now)
    Status.select('distinct (account_id)').where(local: true, created_at: timespan).count
  end

  def contact_account
    Account.find_local(Setting.site_contact_username.strip.gsub(/\A@/, ''))
  end

  def rules
    Rule.ordered
  end

  def user_count
    if ENV['LIAR']
      2_000_000 + Rails.cache.fetch('user_count') { User.confirmed.joins(:account).merge(Account.without_suspended).count }
    else
      Rails.cache.fetch('user_count') { User.confirmed.joins(:account).merge(Account.without_suspended).count }
    end
  end

  def active_user_count(num_weeks = 4)
    Rails.cache.fetch("active_user_count/#{num_weeks}") { ActivityTracker.new('activity:logins', :unique).sum(num_weeks.weeks.ago) }
  end

  def active_user_count_month(months: 6)
    Rails.cache.fetch("active_user_count_month_#{months}") { Redis.current.pfcount(*(0..months).map { |i| "activity:logins_month:#{i.months.ago.utc.to_date.cweek}" }) }
  end

  def status_count
    if ENV['LIAR']
      100_000_000 + Rails.cache.fetch('local_status_count') { Account.local.joins(:account_stat).sum('account_stats.statuses_count') }.to_i
    else
      Rails.cache.fetch('local_status_count') { Account.local.joins(:account_stat).sum('account_stats.statuses_count') }.to_i
    end
  end

  def domain_count
    Rails.cache.fetch('distinct_domain_count') { Instance.count }
  end

  def sample_accounts
    Rails.cache.fetch('sample_accounts', expires_in: 12.hours) { Account.local.discoverable.popular.limit(3) }
  end

  def version_number
    Mastodon::Version
  end

  def source_url
    Mastodon::Version.source_url
  end

  def thumbnail
    @thumbnail ||= Rails.cache.fetch('site_uploads/thumbnail') { SiteUpload.find_by(var: 'thumbnail') }
  end

  def hero
    @hero ||= Rails.cache.fetch('site_uploads/hero') { SiteUpload.find_by(var: 'hero') }
  end

  def mascot
    @mascot ||= Rails.cache.fetch('site_uploads/mascot') { SiteUpload.find_by(var: 'mascot') }
  end
end

# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, :data
    policy.img_src     :self, :data
    policy.object_src  :none
    policy.script_src  :self
    policy.style_src   :self
    policy.connect_src :self
    policy.base_uri    :none
    policy.form_action :self
  end

  # importmap-rails renders the importmap and entry-point <script> tags inline,
  # so they need a per-request nonce to be allowed under script-src :self.
  # Note: session.id can be blank before anything is written to the session
  # (e.g. on the first request, or in some test/headless-browser setups),
  # which would render an empty 'nonce-' and break every inline script -
  # so a random nonce is generated per request instead.
  config.content_security_policy_nonce_generator = ->(request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w(script-src)

  # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end

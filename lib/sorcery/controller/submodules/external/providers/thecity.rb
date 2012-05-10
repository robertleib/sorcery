module Sorcery
  module Controller
    module Submodules
      module External
        module Providers
          # This module adds support for OAuth with facebook.com.
          # When included in the 'config.providers' option, it adds a new option, 'config.facebook'.
          # Via this new option you can configure Facebook specific settings like your app's key and secret.
          #
          #   config.facebook.key = <key>
          #   config.facebook.secret = <secret>
          #   ...
          #
          module TheCity
            def self.included(base)
              base.module_eval do
                class << self
                  attr_reader :thecity                           # access to thecity_client.
                  
                  def merge_thecity_defaults!
                    @defaults.merge!(:@thecity => TheCityClient)
                  end
                end
                merge_thecity_defaults!
                update!
              end
            end
          
            module TheCityClient
              class << self
                attr_accessor :key,
                              :secret,
                              :callback_url,
                              :site,
                              :auth_url,
                              :token_url,
                              :user_info_url,
                              :scope,
                              :user_info_mapping
                attr_reader   :access_token

                include Protocols::Oauth2
            
                def init
                  @site           = "https://auththentication.onthecity.org"
                  @user_info_url = "/me"
                  @scope          = "email,profile-public"
                  @user_info_mapping = {}
                  @token_url      = "/oauth2/access_token"
                  @auth_url       = "/oauth2/authorize"
                end
                
                def get_user_hash
                  user_hash = {}
                  response = @access_token.get(@user_info_path)
                  user_hash[:user_info] = JSON.parse(response.body)
                  user_hash[:uid] = user_hash[:user_info]['id']
                  user_hash
                end
                
                def has_callback?
                  true
                end
                
                # calculates and returns the url to which the user should be redirected,
                # to get authenticated at the external provider's site.
                def login_url(params,session)
                  self.authorize_url
                end
                
                # tries to login the user from access token
                def process_callback(params,session)
                  args = {}
                  args.merge!({:code => params[:code]}) if params[:code]
                  options = {
                    :access_token_path => @token_url,
                    :access_token_method => :post
                  }
                  @access_token = self.get_access_token(args, options)
                end
                
              end
              init
            end
            
          end
        end    
      end
    end
  end
end

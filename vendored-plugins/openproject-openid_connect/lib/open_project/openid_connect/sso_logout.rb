module OpenProject
  module OpenIDConnect
    module SSOLogout
      include LobbyBoy::SessionHelper

      def session_expired?
        super || (current_user.logged? && id_token_expired?)
      end

      ##
      # Upon reauthentication just return directly with HTTP 200 OK
      # and do not reset the session.
      # If not call super which will reset the session, set
      # the new user, and redirect to some page the script the
      # reauthentication doesn't care about.
      def successful_authentication(user)
        if reauthentication?
          finish_reauthentication!
        else
          super
        end
      end

      def logout
        if params.include? :script
          logout_user

          return finish_logout!
        end

        # If the user may view the site without being logged in we redirect back to it.
        site_open = !(Setting.login_required? && ::Concerns::OmniauthLogin.direct_login?)
        return_url = site_open && "#{Setting.protocol}://#{Setting.host_name}"

        if logout_at_op! return_url
          logout_user
        else
          super
        end
      end
    end
  end
end

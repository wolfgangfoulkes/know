class ConfirmationsController < Devise::ConfirmationsController

      # THIS METHOD TRIES TO COMPLETE OBJECT, AND REDIRECTS IF OBJECT IS INCOMPLETE
      def show
        # is token at params[:confirmation_token]? .present? reurns true/false
        if params[:confirmation_token].present?
          @original_token = params[:confirmation_token]
        # is token in params[:resource_name]? .try returns value/nil
        elsif params[resource_name].try(:[], :confirmation_token).present?
          @original_token = params[resource_name][:confirmation_token]
        end

        # find by confirmation token, as in 'confirm'
        self.resource = resource_class.find_by_confirmation_token Devise.token_generator.digest(self, :confirmation_token, @original_token)

        # call devise's method if no-resource-for-token, or resource-is-confirmed
        # it's been nil
        super if resource.nil? or resource.confirmed?
      end

      # THIS METHOD TRIES TO CONFIRM, AND REDIRECTS IF OBJECT IS INCOMPLETE
      # example url in email:
      # /users/confirmation?confirmation_token=ZYGmH7rWn9zk4yxsJmVs
      def confirm
        # check in params[:user] for token or nil
        @original_token = params[resource_name].try(:[], :confirmation_token)
        # digest that token
        digested_token = Devise.token_generator.digest(self, :confirmation_token, @original_token)
        # use the digested token to find the user
        self.resource = resource_class.find_by_confirmation_token! digested_token
        # assign the permitted params (from which page?) 
        # UNLESS user params aren't submitted
        resource.assign_attributes(permitted_params) unless params[resource_name].nil?

        # if validation doesn't throw, and my custom method User.password_match truths
        # confirm!
        # set confirmation message (located in devise.en.yml)
        # redirect to signed_in_user_path
        if resource.valid? && resource.password_match?
          self.resource.confirm!
          set_flash_message :notice, :confirmed
          sign_in_and_redirect resource_name, resource
        else
          render :action => 'show'
        end
      end

  private
       def permitted_params
         params.require(resource_name).permit(:name, :email, :confirmation_token, :password, :password_confirmation)
       end
end
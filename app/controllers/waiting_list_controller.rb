class WaitingListController < ApplicationController
  skip_before_action :verify_authenticity_token, :authenticate_user!

    def add_user
        # Setup the keys needed to access Mailchimp's API
        dc = 'us8'
        unique_id = ENV["MAILCHIMP_LIST_ID"]
        url = "https://#{dc}.api.mailchimp.com/3.0/lists/#{unique_id}/members"
        api_key = ENV["MAILCHIMP_API_TOKEN"]

        # You need to pass the status:subscribed field to ensure the user is subscribed
        user_details = {
          email_address: params[:email_address],
          status: "subscribed",
        }

        # Create a new connection using Faraday
        conn = Faraday.new(
        url: "#{url}?skip_merge_validation=true",
        headers: {'Content-Type' => 'application/json', 'Authorization': "Bearer #{api_key}"}
      )


        response = conn.post() do |req|
          req.body = user_details.to_json
        end

        puts response.body

        # Parse the JSON response sent back from the Mailchimp servers
        response_body = JSON.parse(response.body)

        # Check if the subscription is successful
        if response.status == 200

          redirect_to root_path
          flash[:alert] = "#{user_details[:email_address]} has been added to the waiting list"

        else

          redirect_to root_path
          flash[:alert] = response_body["detail"]

        end

      # skip_authorization
    end
end

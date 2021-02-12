require 'rails_helper.rb'

RSpec.describe "Posts with authentication", type: :request do
  let!(:user) {create(:user)}
  let!(:other_user) {create(:user)}
  let!(:user_post) {create(:post, user_id: user.id)}
  let!(:other_user_post) {create(:post, user_id: other_user.id,published: true)}
  let!(:other_user_post_draft) {create(:post, user_id: other_user.id,published: false )}
  let!(:auth_headers){{'Authorization'=>"Bearer #{user.auth_token}"}}
  let!(:other_auth_headers){{'Authorization'=>"Bearer #{other_user.auth_token}"}}
  let!(:create_params){{"post"=>{"title"=> "title", "content"=>"content","published"=> true}}}
  let!(:update_params){{"post"=>{"title"=>"hola","content"=>"something","published"=>true}}}
  describe "GET /posts/{id}" do
    context "with valid auth" do
      before { allow(JsonWebToken).to receive(:verify).and_return([{email: user.email}]) }
      context "when requesting other's author post" do
        context "when post is public" do
          before {get "/posts/#{other_user_post.id}",headers: auth_headers}
          context "payload" do
            subject {payload}
            it { is_expected.to include(:id)}
          end
          #response
          context "response" do
            subject {response}
            it {is_expected.to have_http_status(:ok)}  
          end
        end

        context "when post is draft" do
          before {get "/posts/#{other_user_post_draft.id}",headers: auth_headers}
          context "payload" do
            subject {payload}
            it { is_expected.to include(:error)}
          end
          #response
          context "response" do
            subject {response}
            it {is_expected.to have_http_status(:not_found)}  
          end
        end
      end
      context "when requesting user's post"
    end

  end
  
  describe "POST /posts" do
    context "with valid auth" do
      before { allow(JsonWebToken).to receive(:verify).and_return([{email: user.email}]) }
      before {post "/posts/",params: create_params,headers: auth_headers}
      context "payload" do
        subject {payload}
        it { is_expected.to include(:id,:title,:content,:published,:author)}

      end
      #response
      context "response" do
        subject {response}
        it {is_expected.to have_http_status(:created)}  
      end
    end
    context "without valid auth" do
      before {post "/posts",params: create_params}
      context "payload" do
        subject {payload}
        it { is_expected.to include(:error)}

      end
      #response
      context "response" do
        subject {response}
        it {is_expected.to have_http_status(:unauthorized)}  
      end
    end
  end
    
  describe "PUT /posts" do
    context "with valid auth" do
      before { allow(JsonWebToken).to receive(:verify).and_return([{email: user.email}]) }
      context "when updating user post" do
        before {put "/posts/#{user_post.id}",params: update_params,headers: auth_headers}
        context "payload" do
          subject {payload}
          it { is_expected.to include(:id,:title,:content,:published,:author)}
          it { expect(payload[:id]).to eq(user_post.id)}

        end
        #response
        context "response" do
          subject {response}
          it {is_expected.to have_http_status(:ok)}  
        end
      end
      context "when updating other user post"do
        before {put "/posts/#{other_user_post.id}",params: update_params,headers: auth_headers}
        context "payload" do
          subject {payload}
          it { is_expected.to include(:error)}

        end
        #response
        context "response" do
          subject {response}
          it {is_expected.to have_http_status(:not_found)}  
        end
      end
    end
  end
  private

  def payload
    JSON.parse(response.body).with_indifferent_access
  end
#    it "should return OK" do
 #     get '/posts'
  #    payload = JSON.parse(response.body)
   #   expect(payload).to be_empty
    #  expect(response).to have_http_status(200)
    #end
  #end
end
require 'rails_helper'

RSpec.describe "Users", type: :request do

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)
  end

  let(:user_params) { 
    {
      name: 'rspec',
      email: 'rspec@gmail.com',
      phone: '09213456543',
      address: 'address test',
      dob: "2022-10-31",
      user_type: 'User'
    }
  }

  let(:invalid_params) {
    {
      name: '',
      email: '',
      phone: '09213456543',
      address: 'address test',
      dob: "2022-10-31",
      user_type: 'User'
    }
  }
  # User Login
  context "POST /posts" do
    it 'invalid credentials' do
      post "/login", params: {
        user: {
          email: 'rspec@test.com',
          password: 'a'
        }
      }
      expect(subject).to render_template(:login)
    end

    it 'valid credentials' do
      post "/login", params: {
        user: {
          email: 'admin@gmail.com',
          password: 'password'
        }
      }
      expect(subject).to redirect_to(posts_path)
    end
  end

  # User List
  context "GET /users" do
    it 'User List'do
      get "/users"
      expect(response).to render_template(:index)
    end
  end

  # User Create
  context "POST /users/new" do
    it 'User Create with valid data' do
      user_params[:password] = 'password'
      user_params[:password_confirmation] = 'password'
      post "/users", params: { user: user_params }
      expect(flash[:notice]).to eq('User created successfully')
    end

    it 'User Create with invalid data' do
      user_params[:password] = 'password'
      user_params[:password_confirmation] = 'pass'
      post "/users", params: { user: invalid_params }
      expect(response).to render_template(:new)
      expect(response).to have_http_status(422)
    end

  end

  # User Show Details
  context "GET /users/:id" do
    it 'User Show Details' do
      user = User.last
      get "/users/#{user.id}"
      expect(response).to have_http_status(200)
      expect(response).to render_template(:show)
    end
  end

  # User Update
  context "PATCH /users/:id/edit" do
    it 'User Update with valid data' do
      user = User.last
      patch "/users/#{user.id}", params: { user: user_params }
      expect(flash[:notice]).to eq('User updated successfully')
    end

    it 'User Update with invalid data' do
      user = User.last
      patch "/users/#{user.id}", params: { user: invalid_params }
      expect(response).to render_template(:edit)
      expect(response).to have_http_status(422)
    end

  end

  # Delete User
  context 'DELETE users/:id' do
    it 'User Delete' do
      user = User.last
      delete "/users/#{user.id}"
      expect(flash[:notice]).to eq('User deleted successfully')
    end
  end

  # Send Password Reset Link
  context 'POST /password/reset' do
    it 'Send Password Reset Link' do
      post '/password/reset', params: { email: current_user.email }
      expect(response).to redirect_to(root_path)
    end
  end

end

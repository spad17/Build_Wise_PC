class BuildsController < ApplicationController
  before_action :require_login

  def index
    @builds = []
  end
end

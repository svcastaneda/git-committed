require 'will_paginate/array'
class ProfilesController < ApplicationController

  def index
    if current_user
      filtered = Profile.order(updated_at: :desc).where.not(id: current_user.profile.id).select {|profile| fits_filter(profile)}
      @profiles = filtered.shuffle.paginate(:per_page => 10)
    else
      redirect_to login_path
    end
  end

  def show
    @profile = Profile.find_by(id: params[:id])
    if @profile
      @user = @profile.user
    else
      redirect_to login_path #change to 404 page path
    end
  end

  def edit
    @profile = Profile.find_by(id: params[:id])
    @user = current_user
    @genders = Gender.all
    @programming_languages = Language.all
    @text_editors = TextEditor.all
    @operating_systems = OperatingSystem.all
    @skills = Skill.all
    @relationship_types = RelationshipType.all
    @sexual_preferences = SexualPreference.all
    @sexual_orientations = SexualOrientation.all
    @user_languages = @user.languages
    @user_skills = @user.skills

    if @profile != current_user.profile
      redirect_to edit_profile_path(current_user.profile)
    end

  end

  def update
    @profile = Profile.find(params[:id])
    @user = User.find(current_user.id)
    @profile.update_attributes(update_profile)
    @user.update_attributes(update_user)

    update_user_languages = params[:languages]
    update_user_languages.each do |language|
      selection_value = language.last
      if selection_value == "1"
       lang = Language.find_by(id: language.first.to_i)
       @user.languages.push(lang) unless @user.languages.include?(lang)
      end
    end

    update_user_editors = params[:editors]
    update_user_editors.each do |editor|
      selection_value = editor.last
      if selection_value == "1"
        text_editor = TextEditor.find_by(id: editor.first.to_i)
        @user.text_editors.push(text_editor) unless @user.text_editors.include?(text_editor)
      end
    end

    update_operating_systems = params[:operating_systems]
    update_operating_systems.each do |op_system|
      selection_value = op_system.last
      if selection_value == "1"
        o_s = OperatingSystem.find_by(id: op_system.first.to_i)
        @user.operating_systems.push(o_s) unless @user.operating_systems.include?(o_s)
      end
    end

    redirect_to profile_path(@profile)
 end

  private
  def update_profile
    params.require(:profile).permit(:about_me, :github_link, :picture)
  end

  def update_user
    params.require(:user).permit(:username,
                                 :first_name,
                                 :last_name,
                                 :email,
                                 :gender_id,
                                 :language_id,
                                 :text_editor_id,
                                 :operating_system_id,
                                 :skill_id,
                                 :seeking_id,
                                 :sexual_preference_id,
                                 :sexual_orientation_id)
  end

  def fits_filter(profile)
    return profile if get_user_filters.any? {|det| profile.get_traits.include?(det)}
  end
end

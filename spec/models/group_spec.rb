require 'rails_helper'

RSpec.describe Group, type: :model do
  let(:organization) { GitHubFactory.create_owner_classroom_org }
  let(:grouping)     { Grouping.create(title: 'Grouping 1', organization: organization) }

  describe 'callbacks', :vcr do
    let(:organization) { GitHubFactory.create_owner_classroom_org }
    let(:grouping)     { Grouping.create(title: 'Grouping 1', organization: organization) }

    before(:each) do
      @group = Group.create(grouping: grouping, title: 'Toon Town')
    end

    after(:each) do
      @group.destroy if @group
    end

    describe 'before_validation' do
      describe '#create_github_team' do
        it 'creates the team on GitHub' do
          assert_requested :post, github_url("/organizations/#{organization.github_id}/teams")
        end
      end
    end

    describe 'assocation callbacks' do
      let(:user) { GitHubFactory.create_classroom_student }

      before(:each) do
        @repo_access = RepoAccess.create(user: user, organization: organization)
        @group.repo_accesses << @repo_access
      end

      after(:each) do
        @repo_access.destroy if @repo_access
      end

      describe 'before_add' do
        describe '#add_member_to_github_team' do
          it 'adds the user to the GitHub team' do
            github_user     = GitHubUser.new(@repo_access.user.github_client)
            memberships_url = "teams/#{@group.github_team_id}/memberships/#{github_user.login}"

            assert_requested :put, github_url(memberships_url)
            assert_requested :patch, github_url("/user/memberships/orgs/#{organization.title}")
          end
        end
      end

      describe 'before_destroy' do
        describe '#remove_from_github_team' do
          it 'removes the user from the GitHub team'do
            github_user = GitHubUser.new(@repo_access.user.github_client)

            @group.repo_accesses.delete(@repo_access)
            assert_requested :delete, github_url("/teams/#{@group.github_team_id}/memberships/#{github_user.login}")
          end
        end
      end
    end
  end
end

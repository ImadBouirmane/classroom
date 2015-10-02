module StarterCode
  include GitHub
  extend ActiveSupport::Concern

  def starter_code_repository_id(repo_name)
    return unless repo_name.present?

    begin
      github_repository = GitHubRepository.new(current_user.github_client, nil)
      github_repository.repository(repo_name).id
    rescue ArgumentError => err
      raise GitHub::Error, err.message
    end
  end
end

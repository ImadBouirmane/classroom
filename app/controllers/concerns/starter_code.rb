module StarterCode
  include GitHub
  extend ActiveSupport::Concern

  def starter_code_repository_id(repo_name)
    return unless repo_name.present?

    if repo_name =~ /[a-zA-Z0-9_-]+\/[a-zA-Z0-9_-]+/i
      begin
        github_repository = GitHubRepository.new(current_user.github_client, nil)
        github_repository.repository(repo_name).id
      rescue ArgumentError => err
        raise GitHub::Error, err.message
      end
    else
      raise GitHub::Error, 'Invalid repository format'
    end
  end
end

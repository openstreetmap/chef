name "chef-repository"
description "Role applied to all chef repositories"

default_attributes(
  :accounts => {
    :users => {
      :jochen => {
        :status => :user,
        :shell => "/usr/bin/git-shell",
      },
      :lonvia => {
        :status => :user,
        :shell => "/usr/bin/git-shell",
      },
      :stereo => {
        :status => :user,
        :shell => "/usr/bin/git-shell",
      },
      :yellowbkpk => {
        :status => :user,
        :shell => "/usr/bin/git-shell",
      },
      :chefrepo => {
        :status => :role,
        :members => [
          :tomh, :grant, :matt, :jburgess, :lonvia, :yellowbkpk, :bretth, :jochen, :stereo
        ],
      },
    },
  },
  :chef => {
    :public_repository => "/var/lib/git/public/chef.git",
    :private_repository => "/var/lib/git/private/chef.git",
  }
)

run_list(
  "recipe[chef::repository]"
)

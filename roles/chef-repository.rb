name "chef-repository"
description "Role applied to all chef repositories"

default_attributes(
  :accounts => {
    :users => {
      :lonvia => {
        :status => :user,
        :shell => "/usr/bin/git-shell"
      },
      :yellowbkpk => {
        :status => :user,
        :shell => "/usr/bin/git-shell"
      },
      :chefrepo => {
        :status => :role,
        :members => [ :tomh, :grant, :matt, :jburgess, :lonvia, :yellowbkpk ]
      }
    }
  },
  :chef => {
    :repository => "/var/lib/git/chef.git"
  }
)

run_list(
  "recipe[chef::repository]"
)

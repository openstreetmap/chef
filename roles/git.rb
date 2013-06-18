name "git"
description "Role applied to all git servers"

default_attributes(
  :accounts => {
    :users => {
      :lonvia => {
        :status => :user,
        :shell => "/usr/bin/git-shell"
      },
      :translatewiki => {
        :status => :user,
        :shell => "/usr/bin/git-shell"
      },
      :git => {
        :status => :role,
        :members => [ :tomh, :grant, :matt, :lonvia, :translatewiki ]
      }
    }
  },
  :git => {
    :host => "git.openstreetmap.org",
    :directory => "/var/lib/git"
  }
)

run_list(
  "recipe[git::server]"
)

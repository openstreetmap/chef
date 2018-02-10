name "git"
description "Role applied to all git servers"

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
      :git => {
        :status => :role,
        :members => [:tomh, :grant, :matt, :lonvia, :yellowbkpk]
      }
    }
  },
  :git => {
    :host => "git.openstreetmap.org",
    :aliases => ["git.osm.org"],
    :backup => "git"
  }
)

run_list(
  "recipe[git::server]",
  "recipe[git::web]"
)

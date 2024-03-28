name "angor"
description "Master role applied to angor"

default_attributes(
  :networking => {
    :interfaces => {
      :external => {
        :interface => "eno1",
        :role => :external,
        :inet => {
          :address => "196.10.54.165",
          :prefix => "29",
          :gateway => "196.10.54.161"
        },
        :inet6 => {
          :address => "2001:43f8:1f4:b00:b283:feff:fed8:dd45",
          :prefix => "64",
          :gateway => "2001:43f8:1f4:b00::1"
        }
      }
    }
  },
  :accounts => {
    :users => {
      :htonl => { :status => :user },
      :gmoncrieff => { :status => :user },
      :zander => { :status => :user },
      :"za-imagery" => {
          :status => :role,
          :members => [:grant, :htonl, :gmoncrieff, :zander]
      }
    }
  }
)

run_list(
  "role[inxza]"
)

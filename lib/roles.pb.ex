defmodule Empty do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{}
  defstruct []
end

defmodule User do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: String.t()
        }
  defstruct [:id]

  field(:id, 1, type: :string)
end

defmodule UserRolesList do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          users: [UserRolesList.RoleSet.t()]
        }
  defstruct [:users]

  field(:users, 1, repeated: true, type: UserRolesList.RoleSet)
end

defmodule UserRolesList.RoleSet do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: String.t(),
          roles: [String.t()]
        }
  defstruct [:id, :roles]

  field(:id, 1, type: :string)
  field(:roles, 2, repeated: true, type: :string)
end

defmodule AllUserRolesList do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          users: [UserRolesList.t()]
        }
  defstruct [:users]

  field(:users, 1, repeated: true, type: UserRolesList)
end

defmodule RoleService.Service do
  @moduledoc false
  use GRPC.Service, name: "RoleService"

  rpc(:Get, User, UserRolesList)
end

defmodule RoleService.Stub do
  @moduledoc false
  use GRPC.Stub, service: RoleService.Service
end

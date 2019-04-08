defmodule Empty do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{}
  defstruct []
end

defmodule Status do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          success: boolean
        }
  defstruct [:success]

  field(:success, 1, type: :bool)
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

defmodule RoleDiff do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          id: String.t(),
          assign: [String.t()],
          revoke: [String.t()]
        }
  defstruct [:id, :assign, :revoke]

  field(:id, 1, type: :string)
  field(:assign, 2, repeated: true, type: :string)
  field(:revoke, 3, repeated: true, type: :string)
end

defmodule ProvisionService.Service do
  @moduledoc false
  use GRPC.Service, name: "ProvisionService"

  rpc(:Get, User, UserRolesList)
  rpc(:Provision, RoleDiff, Status)
end

defmodule ProvisionService.Stub do
  @moduledoc false
  use GRPC.Stub, service: ProvisionService.Service
end

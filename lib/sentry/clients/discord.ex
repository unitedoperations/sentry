# Copyright (C) 2019  United Operations
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

defmodule Sentry.Clients.Discord do
  @moduledoc """
  GRPC client wrapper for interacting with the UO 
  Authenticator API to gather information about users
  in Discord.
  """

  @doc """
  Call the GRPC service's `get` operation for a single user ID.
  """
  def get(id) when is_binary(id) do
    case connect() do
      {:ok, channel} ->
        channel
        |> RoleService.Stub.get(%{id: id})
        |> (fn res -> {:ok, res} end).()

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Call the GRPC service's `get` operation for a list of
  user IDs.
  """
  def get(ids) when is_list(ids) do
    case connect() do
      {:ok, channel} ->
        payload = Enum.map(ids, fn id -> %{id: id} end)
        channel |> RoleService.Stub.get(payload) |> (fn res -> {:ok, res} end).()

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp connect(opts \\ []),
    do: GRPC.Stub.connect(Application.get_env(:uo_sentry, :grpc_url), opts)
end

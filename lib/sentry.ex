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

defmodule Sentry do
  @moduledoc """
  Base functionality module for running the daemon
  operations, kicking off permission and role
  provisioning for all existing users, and interacting
  with community APIs.
  """

  alias Sentry.Clients.Datastore
  alias Sentry.Clients.Forums
  alias Sentry.Clients.Teamspeak
  alias Sentry.Clients.Discord

  @doc """
  Entry point for the Sentry daemon.
  Gathers all existing authenticated users in the system
  and proceeds to reprovision each's permissions.
  """
  def start do
    users = get_users()
    IO.puts("==> Beginning persistence for #{length(users)} users <==")

    discord_users =
      users
      |> Enum.map(fn u -> Map.get(u, "discord_id") end)
      |> (fn x -> Discord.get(Enum.at(x, 0)) end).()
      |> (fn res ->
            case res do
              {:ok, %UserRolesList{users: user_list}} ->
                user_list

              {:error, reason} ->
                IO.puts(reason)
                exit(:shutdown)
            end
          end).()

    IO.puts("==> Fetched Discord roles for all existing users <==")

    if length(users) > 0 do
      Enum.map(users, fn u ->
        [
          Map.get(u, :username),
          Map.get(u, :forums_id),
          Map.get(u, :teamspeak_db_id),
          Map.get(u, :discord_id)
        ]
      end)
      |> Enum.map(fn [username | ids] -> get_roles(username, List.to_tuple(ids)) end)
    end

    IO.puts("==> Completed permissions persistence task <==")
  end

  defp get_users do
    Datastore.get!(:all)
    |> Map.get(:body)
    |> Keyword.get(:users)
  end

  defp get_roles(username, {forums_id, ts_id, discord_id}) do
    IO.puts("==> Gathering roles for #{username} <==")
    forums = Forums.get!(forums_id)
    ts = Teamspeak.get!(ts_id)
  end
end

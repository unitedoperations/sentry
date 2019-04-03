## Copyright (C) 2019  United Operations
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <https://www.gnu.org/licenses/>.

defmodule Sentry do
  @moduledoc false

  alias Sentry.Clients

  def start do
    users = get_users()
    IO.puts("==> Beginning persistence for #{length(users)} users <==")

    if length(users) > 0 do
      Enum.map(users, fn u ->
        {
          Map.get(u, :username),
          Map.get(u, :forums_id),
          Map.get(u, :teamspeak_db_id),
          Map.get(u, :discord_id)
        }
      end)
      |> Enum.map(&get_roles/1)
    end

    IO.puts("==> Completed permissions persistence task <==")
  end

  defp get_users do
    Clients.Datastore.get!(:all)
    |> Map.get(:body)
    |> Keyword.get(:users)
  end

  defp get_roles({username, forums_id, ts_db_id, discord_id}) do
    IO.puts("==> Gathering roles for #{username} <==")
    forums = Clients.Forums.get!(forums_id)
    ts = Clients.Teamspeak.get!(ts_db_id)
  end
end

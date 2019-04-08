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

defmodule Sentry.Groups do
  @moduledoc """
  Performs computations for finding diffs between sets
  of groups and determining which groups to revoke or
  assign on each platform based on a known set of groups.
  """

  @relevant_groups %{
    # FIXME: Members is not given to all on the forums
    "Members" => %{
      :d => "Members",
      :t => 90
    },
    "Donating Members" => %{
      :d => "Donors",
      :t => 27
    },
    "Donating Officer" => %{
      :d => nil,
      :t => 25
    },
    "Game Server Officer" => %{
      :d => "GSO Officers",
      :t => 11
    },
    "Web Server Officer" => %{
      :d => "WSO Officers",
      :t => 13
    },
    "Public Relations Officer" => %{
      :d => "PSO Officers",
      :t => 10
    },
    "UOAF Officer" => %{
      :d => "AFO Officers",
      :t => 108
    },
    "Regulars" => %{
      :d => "Regulars",
      :t => 86
    },
    "Donating Regulars" => %{
      :d => nil,
      :t => 26
    },
    "MMO - DELEGATES" => %{
      :d => "MMO Delegates",
      :t => nil
    },
    "UOTC Delegate" => %{
      :d => "UOTC Delegates",
      :t => nil
    },
    "UOTC Instructor" => %{
      :d => "UOTC D (Instructor)",
      :t => 23
    }
  }

  @doc """
  Creates a tuple containing the list of groups/roles to assign
  and revoke for Teamspeak and Discord based on the found set from
  the user's forums account.
  """
  def diff(ids, forums, ts, discord) do
    %{
      :ts => analyze(forums, ts, :t) |> Map.put(:id, elem(ids, 1)),
      :discord => analyze(forums, discord, :d) |> Map.put(:id, elem(ids, 2))
    }
  end

  defp analyze(forums, platform, key) do
    known = Enum.map(@relevant_groups, fn {_, v} -> Map.get(v, key) end)

    Enum.reduce(@relevant_groups, [], fn {k, v}, acc ->
      x = Map.get(v, key)

      if Enum.member?(forums, k) and x != nil do
        acc ++ [x]
      else
        acc
      end
    end)
    |> (fn vals ->
          %{
            :assign => to_assign(vals, platform, known),
            :revoke => to_revoke(vals, platform, known)
          }
        end).()
  end

  defp to_revoke(forums, platform, all),
    do: Enum.filter(platform, fn val -> Enum.member?(all, val) and !Enum.member?(forums, val) end)

  defp to_assign(forums, platform, all),
    do: Enum.filter(forums, fn val -> Enum.member?(all, val) and !Enum.member?(platform, val) end)
end

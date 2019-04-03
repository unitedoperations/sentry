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

defmodule Sentry.Groups do
  @moduledoc false

  @relevant_groups %{
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

  def diff(forums, ts, discord) do
    [{ts, :t}, {discord, :d}]
    |> Enum.map(fn {list, key} -> analyze(forums, list, key) end)
  end

  defp analyze(forums, platform, key) do
    mapped_values =
      Enum.reduce(@relevant_groups, [], fn {k, v}, acc ->
        x = Map.get(v, key)

        if Enum.member?(forums, k) and x != nil do
          acc ++ [x]
        else
          acc
        end
      end)

    {to_assign(mapped_values, platform), to_revoke(mapped_values, platform)}
  end

  defp to_revoke(forums, platform),
    do: Enum.filter(platform, fn val -> !Enum.member?(forums, val) end)

  defp to_assign(forums, platform),
    do: Enum.filter(forums, fn val -> !Enum.member?(platform, val) end)
end

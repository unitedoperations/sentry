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

defmodule WatchTower.Groups do
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
    Enum.reduce(
      @relevant_groups,
      %{:d => [revoke: [], assign: []], :t => [revoke: [], assign: []]},
      fn {k, v}, acc ->
        if Enum.member?(forums, k) do
          d_role = Map.get(v, :d)
          t_group = Map.get(v, :t)

          # TODO: check fallthrough
          cond do
            d_role != nil and !Enum.member?(discord, d_role) ->
              acc =
                Map.update(acc, :d, fn x -> Keyword.update!(x, :assign, &(&1 ++ [d_role])) end)

            t_group != nil and !Enum.member?(ts, t_group) ->
              acc =
                Map.update(acc, :t, fn x -> Keyword.update!(x, :assign, &(&1 ++ [t_group])) end)
          end
        end

        acc
      end
    )
  end

  defp analyze_teamspeak(forums, ts) do
    group_ts_ids =
      Enum.reduce(@relevant_groups, [], fn {k, v}, acc ->
        id_val = Map.get(v, :t)

        if Enum.member?(forums, k) and id_val != nil do
          acc ++ [id_val]
        else
          acc
        end
      end)

    {to_assign(group_ts_ids, ts), to_revoke(group_ts_ids, ts)}
  end

  defp analyze_discord(forums, discord) do
    role_names =
      Enum.reduce(@relevant_groups, [], fn {k, v}, acc ->
        role = Map.get(v, :d)

        if Enum.member?(forums, k) and role != nil do
          acc ++ [role]
        else
          acc
        end
      end)

    {to_assign(role_names, discord), to_revoke(role_names, discord)}
  end

  defp to_revoke(forums, platform),
    do: Enum.filter(platform, fn val -> !Enum.member?(forums, val) end)

  defp to_assign(forums, platform),
    do: Enum.filter(forums, fn val -> !Enum.member?(platform, val) end)
end

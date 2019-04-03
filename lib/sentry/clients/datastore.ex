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

defmodule Sentry.Clients.Datastore do
  use HTTPoison.Base

  @endpoint Application.get_env(:uo_sentry, :auth_api_url) <> "/users"

  def process_url(param) do
    case param do
      "all" -> @endpoint
      _ -> @endpoint <> "?username=" <> param
    end
  end

  def process_request_headers(_headers) do
    [
      "X-API-Key": Application.get_env(:uo_sentry, :auth_api_key),
      "Content-Type": "application/json",
      Accept: "application/json"
    ]
  end

  def process_response_body(body) do
    body
    |> Poison.decode!()
    |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)
  end
end

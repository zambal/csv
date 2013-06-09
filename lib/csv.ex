defmodule CSV do
  
  example1 = """
Example:
  csv = \"'mike', '35', 'music'\\n\" <>
        \"'eric', '24', 'fishing'\"

  CSV.parse csv, text_deliminator: ?', fields: [:name, :age, :hobby]

  => {:ok, [[name: \"mike\", age: \"35\", hobby: \"music\"],
      [name: \"eric\", age: \"24\", hobby: \"fishing\"]]} 
"""

  @moduledoc """
This module provides parsing of comma seperated value (csv) files.

By default, the return type is a list of lists, but keyword lists
are also supported by using the :fields option.

#{example1}
"""

  @doc """
Parses tabular text to a list of lists, or a list of keyword lists, depending on
the specified options.  

Options: :field_deliminator - Specify the field deliminator character. (default: ?,)
         :text_deliminator - Specify the deliminator that encloses a value. (default: ?\")
         :comment - Specify the character(s) that start a comment. (default: \"#\")  
         :skip_first_lines - Skip first N lines. (default: 0)
         :fields - Specify the fields that make up a row. 
                   When a line with more or less fields than specified,
                   parsing is aborted (default: nil)

#{example1}
"""

  def parse(csv, opts // []) do
    opts = Keyword.merge(def_opts, opts)
    {res, _} = Enum.reduce(String.split(csv, "\n"),
                           {[], 1},
                           parse_line(&1, &2, opts))
    if is_list(res) do
      {:ok, Enum.reverse(res)}
    else
      {:error, res}
    end
  end    

  defp parse_line(line, {acc, lnum}, opts)
  when is_list(acc) do                        
    if Regex.match?(%r/^\s*#{opts[:comment]}/, line)
       or line == ""
       or lnum <= opts[:skip_first_lines] do
         {acc, lnum + 1}
    else
      row = String.split(line, list_to_binary([opts[:field_deliminator]]))
      |> Enum.map(strip(&1, opts[:text_deliminator]))
      |> maybe_to_keywords(opts[:fields], lnum)
      if is_list(row) do
        {[row|acc], lnum + 1}
      else
        {row, nil}
      end
    end
  end
  defp parse_line(_line, {error, nil}, _opts) do
    {error, nil}
  end

  defp strip(field, nil) do
    String.strip(field)
  end
  defp strip(field, deliminator) do
    String.strip(field)
    |> String.strip(deliminator)
  end

  defp maybe_to_keywords(row, nil, _lnum) do
    row
  end
  defp maybe_to_keywords(row, field_names, lnum) do
    to_keywords(row, field_names, [], lnum)
  end

  defp to_keywords([f|fields], [n|names], acc, lnum) do
    to_keywords(fields, names, [{n, f}|acc], lnum)
  end
  defp to_keywords([], [], acc, _lnum) do
    Enum.reverse(acc)
  end
  defp to_keywords([], [_|_], _acc, lnum) do
    "Aborted: fields missing in line #{lnum}."
  end
  defp to_keywords([_|_], [], _acc, lnum) do
    "Aborted: too many fields in line #{lnum}."
  end

  defp def_opts do
    [field_deliminator: ?,,
     comment: "#",
     skip_first_lines: 0,
     text_deliminator: ?",
     fields: nil]
  end
end
     

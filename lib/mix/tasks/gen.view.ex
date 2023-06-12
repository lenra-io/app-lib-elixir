defmodule Mix.Tasks.Lenra.Gen.View do
  use Mix.Task
  import Mix.Generator

  @shortdoc "Generate a view for the Lenra app"

  # Option aliases
  @aliases [
    p: :path
  ]

  # Options
  @switches [
    path: :string,
    help: :boolean
  ]

  @base_dir "lib"
  @default_path "views"

  def run(args) do
    case OptionParser.parse!(args, strict: @switches, aliases: @aliases) do
      {[help: true], _} ->
        explain_message()
        |> IO.puts()

      {opts, [module]} ->
        path = opts[:path] || @default_path
        listener_path = Path.join(Mix.Project.config()[:app] |> Atom.to_string(), path)
        gen_module(module, listener_path)

      {_opts, []} ->
        Mix.raise("You MUST specify the module name.\n\n#{explain_message()}")
    end
  end

  def explain_message() do
    """
    mix lenra.gen.view expect a module name.
    For example :

      mix lenra.gen.view Foo
      mix lenra.gen.view Foo --path <custom_view_dir>

    This will generate a view at lib/app/view/foo.ex
    """
  end

  def gen_module(module, view_dir) do
    filename = "#{Macro.underscore(module)}.ex"
    full_module = Macro.camelize(Path.join(view_dir, module))
    full_path = Path.join([@base_dir, view_dir, filename])

    if overwrite?(full_path) do
      view_content = view_template(mod_name: full_module)
      create_file(full_path, view_content)
    end
  end

  embed_template(:view, """
  defmodule <%= @mod_name %> do
    use Lenra.View

    defview _ do
      %{
        "type" => "text",
        "value" => "Hello from <%= @mod_name %>",
      }
    end
  end
  """)
end
